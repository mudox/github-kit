import Foundation

import Kanna

import JacKit

private let jack = Jack().set(format: .short).set(level: .warning)

public extension Trending {

  struct Developer {
    public let avatarURL: URL
    public let name: String
    public let displayName: String?
    public let repositoryName: String
    public let repositoryDescription: String
  }

}

// MARK: - Internal

internal extension Trending.Developer {

  static func list(from htmlString: String) throws -> [Trending.Developer] {
    let log = jack.function()
    log.assertBackgroundThread()

    let doc = try HTML(html: htmlString, encoding: .utf8)

    let selector = """
    div.application-main \
    div.explore-content \
    > ol.list-style-none \
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
        throw Trending.Error.htmlParsing
      }

    }

    var developers = [Trending.Developer]()
    for item in items {
      let developer = try single(from: item)

      jack.debug(dump(of: developer))
      developers.append(developer)
    }
    return developers
  }

}

// MARK: - Fileprivate

fileprivate extension Trending.Developer {

  static func single(from element: Kanna.XMLElement) throws -> Trending.Developer {

    let url = try avatarURL(from: element)
    let (name, displayName) = try names(from: element)
    let (repoName, description) = try repository(from: element)

    return Trending.Developer(
      avatarURL: url,
      name: name,
      displayName: displayName,
      repositoryName: repoName,
      repositoryDescription: description
    )
  }

  static func avatarURL(from element: Kanna.XMLElement) throws -> URL {
    let log = jack.descendant("logo(from:)")

    guard let img = element.css("div > a > img").first else {
      jack.error("failed to get the <img> element which should contain the url of the developer's logo")
      throw Trending.Error.htmlParsing
    }

    guard let urlString = img["src"] else {
      jack.error("`img.src` returned nil, expecting the url of developer logo")
      throw Trending.Error.htmlParsing
    }

    guard let url = URL(string: urlString) else {
      jack.error("invalid url string: \(urlString)")
      throw Trending.Error.htmlParsing
    }

    return url
  }

  static func names(from element: XMLElement) throws -> (name: String, displayName: String?) {
    let log = jack.descendant("names(from:)")

    // Name of developer
    guard let anchor = element.css("div > div > h2 > a").first else {
      jack.error("failed to get the <a> element which should contain the url name of the developer")
      throw Trending.Error.htmlParsing
    }

    guard let anchorText = anchor.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
      jack.error("`anchor.text` returned nil, expecting the url name of the developer")
      throw Trending.Error.htmlParsing
    }

    let name: String
    if let index = anchorText.index(of: "\n") {
      name = anchorText.substring(to: index)
    } else {
      name = anchorText
    }

    // Display name of developer is optional
    let displayName: String?
    if let span = element.css("div > div > h2 > a > span").first {
      guard let text = span.text else {
        jack.error("`span.text` returned nil, expecting the display name of the developer")
        throw Trending.Error.htmlParsing
      }
      displayName = text
    } else {
      displayName = nil
    }

    return (
      name.trimmingCharacters(in: .whitespacesAndNewlines),
      displayName?.trimmingCharacters(in: .whitespacesAndNewlines)
    )
  }

  static func repository(from element: XMLElement) throws -> (name: String, description: String) {
    let log = jack.descendant("repository(from:)")

    guard let span = element.css("div > div > a > span[class^=\"repo-snipit-name\"]").first else {
      jack.error("failed to get the <span> element which should contain the name of the repository")
      throw Trending.Error.htmlParsing
    }

    guard let name = span.text else {
      jack.error("`span.text` returned nil, expecting the name of the repository")
      throw Trending.Error.htmlParsing
    }

    guard let anchor = element.css("div > div > a > span[class^=\"repo-snipit-description\"]").first else {
      jack.error("failed to get the <a> element which should contain the description of the repository")
      throw Trending.Error.htmlParsing
    }

    guard let description = anchor.text else {
      jack.error("`anchor.text` returned nil, expecting the description of the repository")
      throw Trending.Error.htmlParsing
    }

    return (
      name.trimmingCharacters(in: .whitespacesAndNewlines),
      description.trimmingCharacters(in: .whitespacesAndNewlines)
    )
  }

}
