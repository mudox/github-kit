import Foundation

import Kanna

import JacKit

public extension GitHubTrending {

  struct Repository {

    let title: String
    let description: String

    let language: (name: String, color: String)?

    let starsCount: Int
    let forksCount: Int?
    let gainedStarsCount: Int
//
//  let contibutors: [String]
  }
}

// MARK: - Parsing helpers

internal extension GitHubTrending.Repository {

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

internal extension GitHubTrending.Repository {

  static func list(from htmlString: String) -> [GitHubTrending.Repository]? {
    let jack = Jack("GitHubTrending.Repository.list(from:)").set(options: .short)

    guard let doc = try? HTML(html: htmlString, encoding: .utf8) else {
      jack.error("init `Kanna.HTML` failed")
      return nil
    }

    let selector = """
    div.application-main \
    div.explore-content \
    > ol.repo-list \
    > li[id^=pa-]
    """

    let items = doc.css(selector)
    jack.debug("found \(items.count) items", options: .short)

    var repositories = [GitHubTrending.Repository]()
    for item in items {
      guard let repository = single(from: item) else {
        return nil
      }

      jack.debug(Jack.dump(of: repository))
      repositories.append(repository)
    }

    return repositories
  }

}

// MARK: - Fileprivate

fileprivate extension GitHubTrending.Repository {

  static func single(from element: Kanna.XMLElement) -> GitHubTrending.Repository? {

    guard
      let title = title(from: element),
      let description = description(from: element),
      let language = language(from: element),
      let starsCount = starsCount(from: element),
      let gainedStarsCount = gainedStarsCount(from: element)
    else {
      return nil
    }

    let forksCount = self.forksCount(from: element)

    return GitHubTrending.Repository(
      title: title,
      description: description,
      language: language,
      starsCount: starsCount,
      forksCount: forksCount,
      gainedStarsCount: gainedStarsCount
    )

  }

  static func title(from element: Kanna.XMLElement) -> String? {
    let jack = Jack("GitHubTrending.Repository.title(from:)")

    guard let anchor = element.css("div > h3 > a").first else {
      jack.error("failed to get the <a> element which should contain the title of the repository")
      return nil
    }

    guard let name = anchor.text else {
      jack.error("`anchor.text` returned nil, expecting the title of the repository")
      return nil
    }

    return name.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  static func description(from element: Kanna.XMLElement) -> String? {
    let jack = Jack("GitHubTrending.Repository.description(from:)")

    guard let div = element.css("div:nth-child(3)").first else {
      jack.error("failed to get the <div> element which should contain the description of the repository")
      return nil
    }

    guard let description = div.text else {
      jack.error("`div.text` returned nil, expecting the description of the repository")
      return nil
    }

    return description.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  static func language(from element: Kanna.XMLElement) -> (name: String, color: String)? {
    let jack = Jack("GitHubTrending.Repository.language(from:)")

    // Color string

    let colorSelector = """
    div.f6.text-gray.mt-2 \
    > span.d-inline-block.mr-3 \
    > span.repo-language-color.ml-0
    """

    guard let colorSpan = element.css(colorSelector).first else {
      jack.error("failed to get the <span> element which should contain the language color indicator of the repository")
      return nil
    }

    guard let style = colorSpan["style"] else {
      jack.error("`span[style]` returned nil, expecting style string containing color of the repository's language")
      return nil
    }

    guard let colorString = GitHubTrending.Repository.colorString(from: style) else {
      jack.error("failed to extract color string from style string: \(style)")
      return nil
    }

    // Language name
    let nameSelector = """
    div.f6.text-gray.mt-2 \
    > span.d-inline-block.mr-3 \
    > span[itemprop=programmingLanguage]
    """

    guard let nameSpan = element.css(nameSelector).first else {
      jack.error("failed to get the <span> element which should contain the language name of the repository")
      return nil
    }

    guard let name = nameSpan.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
      jack.error("`span.text` returned nil, expecting name of the repository's language")
      return nil
    }

    return (name, colorString)
  }

  static func starsCount(from element: Kanna.XMLElement) -> Int? {
    let jack = Jack("GitHubTrending.Repository.starsCount(from:)")

    let selector = """
    div.f6.text-gray.mt-2 \
    > a[href$=stargazers]
    """

    guard let anchor = element.css(selector).first else {
      jack.error("failed to get the <a> element which should stars count of the repository")
      return nil
    }

    guard let text = anchor.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
      jack.error("`anchor.text` returned nil, expecting stars count of the repository")
      return nil
    }

    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.number(from: text)
    guard let count = formatter.number(from: text) else {
      jack.error("cast string (\(text)) to number failed, expecting stars count of the repository")
      return nil
    }

    return count.intValue
  }

  static func forksCount(from element: Kanna.XMLElement) -> Int? {
    let jack = Jack("GitHubTrending.Repository.forksCount(from:)")

    let selector = """
    div.f6.text-gray.mt-2 \
    > a[href$=network]
    """

    guard let anchor = element.css(selector).first else {
      jack.error("failed to get the <a> element which should contain forks count of the repository")
      return nil
    }

    guard let text = anchor.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
      jack.error("`anchor.text` returned nil, expecting forks count of the repository")
      return nil
    }

    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.number(from: text)
    guard let count = formatter.number(from: text) else {
      jack.error("cast string (\(text)) to number failed, expecting forks count of the repository")
      return nil
    }

    return count.intValue
  }

  static func gainedStarsCount(from element: Kanna.XMLElement) -> Int? {
    let jack = Jack("GitHubTrending.Repository.gainedStarsCount(from:)")

    let selector = """
    div.f6.text-gray.mt-2 \
    > span.d-inline-block.float-sm-right
    """

    guard let span = element.css(selector).first else {
      jack.error("failed to get the <span> element which should gained stars count of the repository")
      return nil
    }

    guard let text = span.text else {
      jack.error("`anchor.text` returned nil, expecting gained stars count of the repository")
      return nil
    }

    guard let range = text.range(of: "\\d+", options: .regularExpression, range: nil, locale: nil) else {
      jack.error("failed to extract gained star count digits from string: \(text)")
      return nil
    }

    let numberText = text.substring(with: range)

    guard let count = Int(numberText) else {
      jack.error("cast string (\(text)) to number failed, expecting gained stars count of the repository")
      return nil
    }

    return count
  }

  static func contributors(from element: Kanna.XMLElement) -> [String]? {
    fatalError("Unimplemented")
  }
}
