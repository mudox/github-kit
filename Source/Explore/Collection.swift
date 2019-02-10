import Foundation

import Yams

import JacKit

private let jack = Jack("GitHub.Collection").set(format: .short)

public struct Collection: Codable {

  public let items: [Item]
  public let creator: String?
  public let displayName: String
  public let description: String
  
  private let logoRelativePath: String?
  public var logoLocalURL: URL? {
    do {
      let baseURL = try Explore.URLs().collections
      if let path = logoRelativePath {
        return URL(string: path, relativeTo: baseURL)
      } else {
        return nil
      }
    } catch {
      return nil
    }
  }

  init(yamlString: String, description: String, directory: String) throws {

    let decoder = YAMLDecoder()
    let decoded = try decoder.decode(YAMLDecoded.self, from: yamlString)

    if let fileName = decoded.image {
      logoRelativePath = "\(directory)/\(fileName)"
    } else {
      logoRelativePath = nil
    }

    items = decoded.items.compactMap(Item.init)
    creator = decoded.created_by
    displayName = decoded.display_name
    self.description = description
  }

}

// MARK: - YAML Representation

private extension Collection {

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

public extension Collection {

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

        jack.func().warn("invalid item string: \(string)")
        return nil
      } catch {
        jack.func().error("error initializing regex patterns: \(error)")
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

extension Collection.Item: Codable {

  private enum CodingKeys: String, CodingKey {
    case base
    case repositoryAssociated
    case gitHubUserAssociated
    case youtubeVideoAssociated
    case siteAssociated
  }

  private enum Base: String, Codable {
    case repository
    case gitHubUser
    case youtubeVideo
    case site
  }

  private struct RepositoryAssociated: Codable {
    let owner: String
    let name: String
  }

  private struct GitHubUserAssociated: Codable {
    let name: String
  }

  private struct YoutubeVideoAssociated: Codable {
    let url: URL
  }

  private struct SiteAssociated: Codable {
    let url: URL
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let base = try container.decode(Base.self, forKey: .base)

    switch base {
    case .repository:
      let assocaited = try container.decode(RepositoryAssociated.self, forKey: .repositoryAssociated)
      self = .repository(owner: assocaited.owner, name: assocaited.name)
    case .gitHubUser:
      let assocaited = try container.decode(GitHubUserAssociated.self, forKey: .gitHubUserAssociated)
      self = .gitHubUser(assocaited.name)
    case .youtubeVideo:
      let assocaited = try container.decode(YoutubeVideoAssociated.self, forKey: .youtubeVideoAssociated)
      self = .youtubeVideo(assocaited.url)
    case .site:
      let assocaited = try container.decode(SiteAssociated.self, forKey: .siteAssociated)
      self = .site(assocaited.url)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case let .repository(owner: owner, name: name):
      try container.encode(Base.repository, forKey: .base)
      try container.encode(RepositoryAssociated(owner: owner, name: name), forKey: .repositoryAssociated)
    case let .gitHubUser(name):
      try container.encode(Base.gitHubUser, forKey: .base)
      try container.encode(GitHubUserAssociated(name: name), forKey: .gitHubUserAssociated)
    case let .youtubeVideo(url):
      try container.encode(Base.youtubeVideo, forKey: .base)
      try container.encode(YoutubeVideoAssociated(url: url), forKey: .youtubeVideoAssociated)
    case let .site(url):
      try container.encode(Base.site, forKey: .base)
      try container.encode(SiteAssociated(url: url), forKey: .siteAssociated)
    }
  }

}
