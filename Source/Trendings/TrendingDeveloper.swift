import Foundation

import Kanna

import JacKit

private let jack = Jack().set(format: .short).set(level: .warning)

public extension Trending {

  struct Developer {
    let logoURL: URL
    let name: String
    let displayName: String?
    let repositoryName: String
    let repositoryDescription: String
  }

}

// MARK: - Internal

internal extension Trending.Developer {
  
  static func list(from htmlString: String) throws -> [Trending.Developer] {
    let log = jack.descendant("list(from:)")
    log.assert(!Thread.isMainThread, "should run on background thread")

    let doc = try HTML(html: htmlString, encoding: .utf8)

    let selector = """
    div.application-main \
    div.explore-content \
    > ol.list-style-none \
    > li[id^=pa-]
    """

    let items = doc.css(selector)
    jack.debug("found \(items.count) items", format: .short)

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

    let logoURL = try logo(from: element)
    let (name, displayName) = try names(from: element)
    let (repoName, description) = try repository(from: element)

    return Trending.Developer(
      logoURL: logoURL,
      name: name,
      displayName: displayName,
      repositoryName: repoName,
      repositoryDescription: description
    )
  }

  static func logo(from element: Kanna.XMLElement) throws -> URL {
    let log = jack.descendant("logo(from:)")

    guard let img = element.css("div > a > img").first else {
      jack.error("failed to get the <img> element which should contain the url of the developer's logo")
      throw Trending.HTMLParsingError()
    }

    guard let urlString = img["src"] else {
      jack.error("`img.src` returned nil, expecting the url of developer logo")
      throw Trending.HTMLParsingError()
    }

    guard let url =  URL(string: urlString) else {
      jack.error("invalid url string: \(urlString)")
      throw Trending.HTMLParsingError()
    }
    
    return url
  }

  static func names(from element: XMLElement) throws -> (name: String, displayName: String?) {
    let log = jack.descendant("names(from:)")

    // Name of developer
    guard let anchor = element.css("div > div > h2 > a").first else {
      jack.error("failed to get the <a> element which should contain the url name of the developer")
      throw Trending.HTMLParsingError()
    }

    guard let anchorText = anchor.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
      jack.error("`anchor.text` returned nil, expecting the url name of the developer")
      throw Trending.HTMLParsingError()
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
        throw Trending.HTMLParsingError()
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
      throw Trending.HTMLParsingError()
    }

    guard let name = span.text else {
      jack.error("`span.text` returned nil, expecting the name of the repository")
      throw Trending.HTMLParsingError()
    }

    guard let anchor = element.css("div > div > a > span[class^=\"repo-snipit-description\"]").first else {
      jack.error("failed to get the <a> element which should contain the description of the repository")
      throw Trending.HTMLParsingError()
    }

    guard let description = anchor.text else {
      jack.error("`anchor.text` returned nil, expecting the description of the repository")
      throw Trending.HTMLParsingError()
    }

    return (
      description.trimmingCharacters(in: .whitespacesAndNewlines),
      name.trimmingCharacters(in: .whitespacesAndNewlines)
    )
  }

}
