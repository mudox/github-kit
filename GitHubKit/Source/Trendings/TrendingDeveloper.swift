import Foundation

import Kanna

import JacKit

public extension GitHubTrending {

  struct Developer {
    let logoURL: URL
    let name: String
    let displayName: String?
    let repositoryName: String
    let repositoryDescription: String
  }

}

// MARK: - Internal

internal extension GitHubTrending.Developer {

  static func list(from text: String) -> [GitHubTrending.Developer]? {
    let jack = Jack("GitHubTrending.Developer.list(from:)").set(options: [.noLocation])

    guard let doc = try? HTML(html: text, encoding: .utf8) else {
      jack.error("init `Kanna.HTML` failed")
      return nil
    }

    let items = doc.css("div.application-main div.explore-content > ol.list-style-none > li[id^=pa-]")
    jack.debug("found \(items.count) items", options: .short)

    var developers = [GitHubTrending.Developer]()
    for item in items {
      guard let developer = single(from: item) else {
        return nil
      }

      jack.debug(Jack.dump(of: developer))
      developers.append(developer)
    }
    return developers
  }

}

// MARK: - Fielprivate

fileprivate extension GitHubTrending.Developer {

  static func single(from element: Kanna.XMLElement) -> GitHubTrending.Developer? {

    guard
      let logoURL = logo(from: element),
      let (name, displayName) = names(from: element),
      let (repoName, description) = repository(from: element)
    else {
      return nil
    }

    return GitHubTrending.Developer(
      logoURL: logoURL,
      name: name,
      displayName: displayName,
      repositoryName: repoName,
      repositoryDescription: description
    )
  }

  static func logo(from element: Kanna.XMLElement) -> URL? {
    let jack = Jack("GitHubTrending.Developer")

    guard let img = element.css("div > a > img").first else {
      jack.error("failed to get the <img> element which should contain the url of the developer's logo")
      return nil
    }

    guard let urlString = img["src"] else {
      jack.error("`img.src` returned nil, expecting the url of developer logo")
      return nil
    }

    return URL(string: urlString)
  }

  static func names(from element: XMLElement) -> (name: String, displayName: String?)? {
    let jack = Jack("GitHubTrending.Developer")

    // Name of developer
    guard let anchor = element.css("div > div > h2 > a").first else {
      jack.error("failed to get the <a> element which should contain the url name of the developer")
      return nil
    }

    guard let anchorText = anchor.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
      jack.error("`anchor.text` returned nil, expecting the url name of the developer")
      return nil
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
        return nil
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

  static func repository(from element: XMLElement) -> (name: String, description: String)? {
    let jack = Jack("GitHubTrending.Developer")

    guard let span = element.css("div > div > a > span[class^=\"repo-snipit-name\"]").first else {
      jack.error("failed to get the <span> element which should contain the name of the repository")
      return nil
    }

    guard let name = span.text else {
      jack.error("`span.text` returned nil, expecting the name of the repository")
      return nil
    }

    guard let anchor = element.css("div > div > a > span[class^=\"repo-snipit-description\"]").first else {
      jack.error("failed to get the <a> element which should contain the description of the repository")
      return nil
    }

    guard let description = anchor.text else {
      jack.error("`anchor.text` returned nil, expecting the description of the repository")
      return nil
    }

    return (
      description.trimmingCharacters(in: .whitespacesAndNewlines),
      name.trimmingCharacters(in: .whitespacesAndNewlines)
    )
  }

}
