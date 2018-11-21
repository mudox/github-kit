import Foundation

import Yams

import JacKit

private let jack = Jack().set(format: .short)

public extension Explore {

  struct Collection {

    /// Initialize an instance of CuratedTopic from an index.md file from github/explore repository.
    ///
    /// - Parameter url: URL of the index.md file.
    public init(yamlString: String, description: String) throws {

      let decoder = YAMLDecoder()
      let decoded = try decoder.decode(YAMLDecoded.self, from: yamlString)

      if let logoFileName = decoded.image {
        let logoBaseName = (logoFileName as NSString).deletingPathExtension
        let url = GitHub.Explore.unzippedDirectoryURL
          .appendingPathComponent("collections/\(logoBaseName)/\(logoFileName)")
        if FileManager.default.fileExists(atPath: url.path) {
          logoLocalURL = url
        } else {
          logoLocalURL = nil
        }
      } else {
        logoLocalURL = nil
      }

      items = decoded.items.compactMap(Item.init)
      creator = decoded.created_by
      displayName = decoded.display_name
      self.description = description
    }

    public let logoLocalURL: URL?
    public let items: [Item]
    public let creator: String?
    public let displayName: String
    public let description: String

  }

}

// MARK: - YAML Representation

private extension Explore.Collection {

  /// YAML reprentation in `github/explore`
  struct YAMLDecoded: Decodable {
    // swiftlint:disable identifier_name
    let image: String?
    let items: [String]
    let created_by: String?
    let display_name: String
    // swiftlint:enable identifier_name
  }

}

public extension Explore.Collection {

  enum Item {

    init?(string: String) {
      do {
        let repoRegex = try NSRegularExpression(pattern: "^\\s*(\\w+)\\s*/\\s*(\\w+)\\s*$")
        let userRegex = try NSRegularExpression(pattern: "^\\s*(\\w+)\\s*$")
        let youtubeRegex = try NSRegularExpression(pattern: "^https://www\\.youtube\\.com/watch\\?.*$")

        let range = NSRange(string.startIndex ..< string.endIndex, in: string)

        // .repository
        if
          let match = repoRegex.firstMatch(in: string, range: range),
          let ownerRange = Range(match.range(at: 1), in: string),
          let nameRange = Range(match.range(at: 2), in: string)
        {
          let owner = String(string[ownerRange])
          let name = String(string[nameRange])
          self = Item.repository(owner: owner, name: name)
          return
        }

        // .gitHubUser
        if
          let match = userRegex.firstMatch(in: string, range: range),
          let range = Range(match.range(at: 1), in: string)
        {
          let name = String(string[range])
          self = Item.gitHubUser(string)
          return
        }

        // .youtubeVideo
        if
          youtubeRegex.numberOfMatches(in: string, range: range) > 0,
          let url = URL(string: string)
        {
          self = Item.youtubeVideo(url)
          return
        }

        // .site
        if
          let url = URL(string: string)
        {
          self = Item.site(url)
          return
        }

        jack.descendant("Item.init").warn("invalid item string: \(string)")
        return nil
      } catch {
        jack.descendant("Item.init").error("error initializing regex patterns: \(error)")
        return nil
      }
    }

    case repository(owner: String, name: String)
    case gitHubUser(String)
    case youtubeVideo(URL)
    case site(URL)

    public var url: URL {
      switch self {
      case let .repository(owner: owner, name: name):
        return URL(string: "https://github.com/\(owner)/\(name)")!
      case let .gitHubUser(name):
        return URL(string: "https://github.com/\(name)")!
      case let .youtubeVideo(url):
        return url
      case let .site(url):
        return url
      }
    }

  }

}
