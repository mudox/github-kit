import Foundation

import Kanna
import SwiftHEXColors

import JacKit

private let jack = Jack().set(level: .warning)

public extension Trending {

  struct Repository {

    public let title: String
    public let summary: String

    public let language: (name: String, color: UIColor?)?

    public let starsCount: Int
    public let forksCount: Int?
    public let gainedStarsCount: Int?

    // swiftlint:disable:next nesting
    public typealias Contributor = (name: String, avatar: URL)
    public let contributors: [Contributor]

    // MARK: - Computed Properties

    public var owner: String {
      guard let owner = title.split(separator: "/").first else {
        jack.sub("owner.getter").error("can not extract repo owner from `.title`")
        return ""
      }
      return String(owner)
    }

    public var name: String {
      guard let name = title.split(separator: "/").last else {
        jack.sub("name.getter").error("can not extract repo name from `.title`")
        return ""
      }
      return String(name)
    }

  }
}

// MARK: - Parsing helpers

internal extension Trending.Repository {

  static func color(from styleText: String) -> UIColor? {
    let pattern = "background-color\\s*:\\s*#([^;]+);"
    let range = NSRange(styleText.startIndex ..< styleText.endIndex, in: styleText)
    guard
      let regex = try? NSRegularExpression(pattern: pattern),
      let match = regex.firstMatch(in: styleText, options: [], range: range),
      let hexRange = Range(match.range(at: 1), in: styleText)
    else { return nil }

    return UIColor(hexString: String(styleText[hexRange]))
  }

}

// MARK: - Internal

internal extension Trending.Repository {

  static func list(from htmlString: String) throws -> [Trending.Repository] {
    let log = jack.sub("list(from:)")
    log.assertBackgroundThread()

    guard let doc = try? HTML(html: htmlString, encoding: .utf8) else {
      log.error("init `Kanna.HTML` failed")
      throw Trending.Error.htmlParsing
    }

    let selector = """
    div.application-main \
    div.explore-content \
    > ol.repo-list \
    > li[id^=pa-]
    """

    let items = doc.css(selector)
    // swiftlint:disable:next empty_count
    if items.count == 0 {
      let range = htmlString.range(
        of: "Trending .* are currently being dissected.",
        options: .regularExpression
      )

      if range != nil {
        throw Trending.Error.isDissecting
      } else {
        log.error("search for repsitory `<ol>` nodes failed")
        throw Trending.Error.htmlParsing
      }

    }

    var repositories = [Trending.Repository]()
    for item in items {
      let repository = try single(from: item)

      log.debug(dump(of: repository))
      repositories.append(repository)
    }

    return repositories
  }

}

// MARK: - Fileprivate

fileprivate extension Trending.Repository {

  static func single(from element: Kanna.XMLElement) throws -> Trending.Repository {
    return Trending.Repository(
      title: try title(from: element),
      summary: try description(from: element),
      language: try language(from: element),
      starsCount: try starsCount(from: element),
      forksCount: try forksCount(from: element),
      gainedStarsCount: try gainedStarsCount(from: element),
      contributors: try contributors(from: element)
    )
  }

  static func title(from element: Kanna.XMLElement) throws -> String {
    let log = jack.sub("title(from:)")

    guard let anchor = element.css("div > h3 > a").first else {
      log.error("failed to get the <a> element which should contain the title of the repository")
      throw Trending.Error.htmlParsing
    }

    guard let name = anchor.text else {
      log.error("`anchor.text` returned nil, expecting the title of the repository")
      throw Trending.Error.htmlParsing
    }

    return name.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  static func description(from element: Kanna.XMLElement) throws -> String {
    let log = jack.sub("description(from:)")

    guard let div = element.css("div:nth-child(3)").first else {
      log.error("failed to get the <div> element which should contain the description of the repository")
      throw Trending.Error.htmlParsing
    }

    guard let description = div.text else {
      log.error("`div.text` returned nil, expecting the description of the repository")
      throw Trending.Error.htmlParsing
    }

    return description.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  static func language(from element: Kanna.XMLElement) throws -> (name: String, color: UIColor?)? {
    let log = jack.sub("language(from:)")

    // Color string

    let colorSelector = """
    div.f6.text-gray.mt-2      \
    > span.d-inline-block.mr-3 \
    > span.repo-language-color.ml-0
    """

    guard let colorSpan = element.css(colorSelector).first else {
      log.debug("""
      failed to get the <span> element which should contain the language color indicator of the repository.
      it may not be an error.
      """)
      return nil
    }

    guard let style = colorSpan["style"] else {
      log.error("`span[style]` returned nil, expecting style string containing color of the repository's language")
      throw Trending.Error.htmlParsing
    }

    guard let color = Trending.Repository.color(from: style) else {
      log.error("failed to extract color string from style string: \(style)")
      throw Trending.Error.htmlParsing
    }

    // Language name
    let nameSelector = """
    div.f6.text-gray.mt-2      \
    > span.d-inline-block.mr-3 \
    > span[itemprop=programmingLanguage]
    """

    guard let nameSpan = element.css(nameSelector).first else {
      log.error("failed to get the <span> element which should contain the language name of the repository")
      throw Trending.Error.htmlParsing
    }

    guard let name = nameSpan.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
      log.error("`span.text` returned nil, expecting name of the repository's language")
      throw Trending.Error.htmlParsing
    }

    return (name, color)
  }

  static func starsCount(from element: Kanna.XMLElement) throws -> Int {
    let log = jack.sub("starsCount(from:)")

    let selector = """
    div.f6.text-gray.mt-2 \
    > a[href$=stargazers]
    """

    guard let anchor = element.css(selector).first else {
      log.error("failed to get the <a> element which should stars count of the repository")
      throw Trending.Error.htmlParsing
    }

    guard let text = anchor.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
      log.error("`anchor.text` returned nil, expecting stars count of the repository")
      throw Trending.Error.htmlParsing
    }

    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.number(from: text)
    guard let count = formatter.number(from: text) else {
      log.error("cast string (\(text)) to number failed, expecting stars count of the repository")
      throw Trending.Error.htmlParsing
    }

    return count.intValue
  }

  static func forksCount(from element: Kanna.XMLElement) throws -> Int? {
    let log = jack.sub("forksCount(from:)")

    let selector = """
    div.f6.text-gray.mt-2 \
    > a[href$=network]
    """

    guard let anchor = element.css(selector).first else {
      log.debug("""
      failed to get the <a> element which should contain forks count of the repository.
      repository may have no forks, return nil.
      """)
      return nil
    }

    guard let text = anchor.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
      log.error("`anchor.text` returned nil, expecting forks count of the repository")
      throw Trending.Error.htmlParsing
    }

    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.number(from: text)
    guard let count = formatter.number(from: text) else {
      log.error("cast string (\(text)) to number failed, expecting forks count of the repository")
      throw Trending.Error.htmlParsing
    }

    return count.intValue
  }

  static func gainedStarsCount(from element: Kanna.XMLElement) throws -> Int? {
    let log = jack.sub("gainedStarsCount(from:)")

    let selector = """
    div.f6.text-gray.mt-2 \
    > span.d-inline-block.float-sm-right
    """

    guard let span = element.css(selector).first else {
      log.debug("""
      failed to get the <span> element which should contain gained stars count of the repository.
      repository may have no gained stars in the period, return nil
      """)
      return nil
    }

    guard let text = span.text else {
      log.error("`anchor.text` returned nil, expecting gained stars count of the repository")
      throw Trending.Error.htmlParsing
    }

    guard let range = text.range(of: "[,0-9]+", options: .regularExpression) else {
      log.error("failed to extract gained star count digits from string: \(text)")
      throw Trending.Error.htmlParsing
    }

    let numberText = text.substring(with: range)

    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    guard let count = formatter.number(from: numberText) else {
      log.error("cast string (\(text)) to number failed, expecting gained stars count of the repository")
      throw Trending.Error.htmlParsing
    }

    return count.intValue
  }

  static func contributors(from element: Kanna.XMLElement) -> [Contributor] {
    let log = jack.sub("contributors(from:)")

    let selector = """
    div.f6.text-gray.mt-2      \
    > span.d-inline-block.mr-3 \
    > a                        \
    > img
    """

    let imgs = element.css(selector)
    // swiftlint:disable:next empty_count
    guard imgs.count > 0 else {
      log.debug(
        "fail to extract contributors, which is possible for some repositories, return []"
      )
      return []
    }

    return imgs.map { img -> Contributor in
      let anchor = img.parent!
      let href = anchor["href"]!
      let avatar = img["src"]!

      // Rip off leading `/`
      let index = href.index(after: href.startIndex)

      return (
        name: href.substring(from: index),
        avatar: URL(string: avatar)!
      )
    }
  }
}
