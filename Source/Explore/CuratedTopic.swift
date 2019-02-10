import Foundation

import Yams

import JacKit

private let jack = Jack("GitHub.CuratedTopics").set(format: .short)

public struct CuratedTopic: Codable {

  /// Lowercase name used in cosntructing the topic's url.
  public let name: String
  /// Formal name used in titles.
  public let displayName: String
  /// Equivalent tags
  public let aliases: String?
  public let related: String?

  public let creator: String?
  public let releaseDate: Date?

  /// Short description.
  public let summary: String
  /// Longer description, markdown syntax allowed.
  public let description: String

  public let url: URL?
  public let githubURL: URL?
  public let wikipediaURL: URL?

  private let logoRelativePath: String?
  public var logoLocalURL: URL? {
    do {
      let baseURL = try Explore.URLs().topics
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

    name = decoded.topic
    displayName = decoded.display_name
    aliases = decoded.aliases
    related = decoded.related

    if let fileName = decoded.logo {
      logoRelativePath = "\(directory)/\(fileName)"
    } else {
      logoRelativePath = nil
    }

    creator = decoded.created_by

    // Parse release date
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM dd, yyyy"
    releaseDate = decoded.released.flatMap(formatter.date)

    summary = decoded.short_description
    self.description = description

    url = decoded.url
    githubURL = decoded.github_url
    wikipediaURL = decoded.wikipedia_url
  }

}

// MARK: - YAML Representation

private extension CuratedTopic {

  struct YAMLDecoded: Decodable {
    // swiftlint:disable identifier_name
    let topic: String
    let aliases: String?
    let related: String?
    let display_name: String
    let created_by: String?
    let logo: String?
    let released: String?
    let short_description: String
    let url: URL?
    let github_url: URL?
    let wikipedia_url: URL?
    // swiftlint:enable identifier_name
  }
}
