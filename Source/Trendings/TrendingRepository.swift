import Foundation

import Kanna

import JacKit

private let jack = Jack().set(format: .short)

public extension Trending {

  struct Repository {

    public let title: String
    public let summary: String

    public let language: (name: String, color: String)?

    public let starsCount: Int
    public let forksCount: Int?
    public let gainedStarsCount: Int

    // swiftlint:disable:next nesting
    public typealias Contributor = (name: String, avatar: URL)
    public let contributors: [Contributor]

    // MARK: - Computed Properties

    public var owner: String {
      guard let owner = title.split(separator: "/").first else {
        jack.error("can not extract repo owner from `.title`")
        return ""
      }
      return String(owner)
    }

    public var name: String {
      guard let name = title.split(separator: "/").last else {
        jack.error("can not extract repo name from `.title`")
        return ""
      }
      return String(name)
    }

  }
}

// MARK: - Parsing helpers

internal extension Trending.Repository {

  static func colorString(from styleText: String) -> String? {
    let nsText = styleText as NSString
    let nsRange = NSRange(location: 0, length: nsText.length)
    let pattern = "background-color\\s*:\\s*#([^;]+);"

    guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
    guard let match = regex.firstMatch(in: styleText, options: [], range: nsRange) else { return nil }

    return nsText.substring(with: match.range(at: 1))
  }

}

// MARK: - Internal

internal extension Trending.Repository {

  static func list(from htmlString: String) throws -> [Trending.Repository] {
    let jack = Jack("GitHub.Trending.Repository.list(from:)").set(format: .short)

    guard let doc = try? HTML(html: htmlString, encoding: .utf8) else {
      jack.error("init `Kanna.HTML` failed")
      throw Trending.HTMLParsingError()
    }

    let selector = """
    div.application-main \
    div.explore-content \
    > ol.repo-list \
    > li[id^=pa-]
    """

    let items = doc.css(selector)
    jack.debug("found \(items.count) items", format: .short)

    var repositories = [Trending.Repository]()
    for item in items {
      let repository = try single(from: item)

      jack.debug(dump(of: repository))
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
    let jack = Jack("GitHub.Trending.Repository.title(from:)")

    guard let anchor = element.css("div > h3 > a").first else {
      jack.error("failed to get the <a> element which should contain the title of the repository")
      throw Trending.HTMLParsingError()
    }

    guard let name = anchor.text else {
      jack.error("`anchor.text` returned nil, expecting the title of the repository")
      throw Trending.HTMLParsingError()
    }

    return name.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  static func description(from element: Kanna.XMLElement) throws -> String {
    let jack = Jack("GitHub.Trending.Repository.description(from:)")

    guard let div = element.css("div:nth-child(3)").first else {
      jack.error("failed to get the <div> element which should contain the description of the repository")
      throw Trending.HTMLParsingError()
    }

    guard let description = div.text else {
      jack.error("`div.text` returned nil, expecting the description of the repository")
      throw Trending.HTMLParsingError()
    }

    return description.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  static func language(from element: Kanna.XMLElement) throws -> (name: String, color: String)? {
    let jack = Jack("GitHub.Trending.Repository.language(from:)")

    // Color string

    let colorSelector = """
    div.f6.text-gray.mt-2      \
    > span.d-inline-block.mr-3 \
    > span.repo-language-color.ml-0
    """

    guard let colorSpan = element.css(colorSelector).first else {
      jack.debug("""
      failed to get the <span> element which should contain the language color indicator of the repository.
      it may not be an error.
      """)
      return nil
    }

    guard let style = colorSpan["style"] else {
      jack.error("`span[style]` returned nil, expecting style string containing color of the repository's language")
      throw Trending.HTMLParsingError()
    }

    guard let colorString = Trending.Repository.colorString(from: style) else {
      jack.error("failed to extract color string from style string: \(style)")
      throw Trending.HTMLParsingError()
    }

    // Language name
    let nameSelector = """
    div.f6.text-gray.mt-2      \
    > span.d-inline-block.mr-3 \
    > span[itemprop=programmingLanguage]
    """

    guard let nameSpan = element.css(nameSelector).first else {
      jack.error("failed to get the <span> element which should contain the language name of the repository")
      throw Trending.HTMLParsingError()
    }

    guard let name = nameSpan.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
      jack.error("`span.text` returned nil, expecting name of the repository's language")
      throw Trending.HTMLParsingError()
    }

    return (name, colorString)
  }

  static func starsCount(from element: Kanna.XMLElement) throws -> Int {
    let jack = Jack("GitHub.Trending.Repository.starsCount(from:)")

    let selector = """
    div.f6.text-gray.mt-2 \
    > a[href$=stargazers]
    """

    guard let anchor = element.css(selector).first else {
      jack.error("failed to get the <a> element which should stars count of the repository")
      throw Trending.HTMLParsingError()
    }

    guard let text = anchor.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
      jack.error("`anchor.text` returned nil, expecting stars count of the repository")
      throw Trending.HTMLParsingError()
    }

    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.number(from: text)
    guard let count = formatter.number(from: text) else {
      jack.error("cast string (\(text)) to number failed, expecting stars count of the repository")
      throw Trending.HTMLParsingError()
    }

    return count.intValue
  }

  static func forksCount(from element: Kanna.XMLElement) throws -> Int {
    let jack = Jack("GitHub.Trending.Repository.forksCount(from:)")

    let selector = """
    div.f6.text-gray.mt-2 \
    > a[href$=network]
    """

    guard let anchor = element.css(selector).first else {
      jack.debug("""
      failed to get the <a> element which should contain forks count of the repository, repository may have no forks.
      """)
      throw Trending.HTMLParsingError()
    }

    guard let text = anchor.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
      jack.error("`anchor.text` returned nil, expecting forks count of the repository")
      throw Trending.HTMLParsingError()
    }

    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.number(from: text)
    guard let count = formatter.number(from: text) else {
      jack.error("cast string (\(text)) to number failed, expecting forks count of the repository")
      throw Trending.HTMLParsingError()
    }

    return count.intValue
  }

  static func gainedStarsCount(from element: Kanna.XMLElement) throws -> Int {
    let jack = Jack("GitHub.Trending.Repository.gainedStarsCount(from:)")

    let selector = """
    div.f6.text-gray.mt-2 \
    > span.d-inline-block.float-sm-right
    """

    guard let span = element.css(selector).first else {
      jack.error("failed to get the <span> element which should gained stars count of the repository")
      throw Trending.HTMLParsingError()
    }

    guard let text = span.text else {
      jack.error("`anchor.text` returned nil, expecting gained stars count of the repository")
      throw Trending.HTMLParsingError()
    }

    guard let range = text.range(of: "[,0-9]+", options: .regularExpression) else {
      jack.error("failed to extract gained star count digits from string: \(text)")
      throw Trending.HTMLParsingError()
    }

    let numberText = text.substring(with: range)
    
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    guard let count = formatter.number(from: numberText) else {
      jack.error("cast string (\(text)) to number failed, expecting gained stars count of the repository")
      throw Trending.HTMLParsingError()
    }

    return count.intValue
  }

  static func contributors(from element: Kanna.XMLElement) -> [Contributor] {
    let jack = Jack("GitHub.Trending.Repository.contributors(from:)")

    let selector = """
    div.f6.text-gray.mt-2      \
    > span.d-inline-block.mr-3 \
    > a                        \
    > img
    """

    let imgs = element.css(selector)
    // swiftlint:disable:next empty_count
    guard imgs.count > 0 else {
      jack.error("fail to extract contributors")
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
