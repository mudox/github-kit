import Foundation

import Yams

import JacKit

public extension Explore {

  struct CuratedTopic {

    /// Initialize an instance of CuratedTopic from an index.md file from github/explore repository.
    ///
    /// - Parameter url: URL of the index.md file.
    /// - Throws: Swift.Decoding.Error
    public init(yamlString: String, description: String) throws {

      let decoder = YAMLDecoder()
      let decoded = try decoder.decode(YAMLDecoded.self, from: yamlString)

      name = decoded.topic
      displayName = decoded.display_name
      aliases = decoded.aliases
      related = decoded.related

      if let logoFileName = decoded.logo {
        let logoBaseName = (logoFileName as NSString).deletingPathExtension
        let url = GitHub.Explore.unzippedDirectoryURL
          .appendingPathComponent("topics/\(logoBaseName)/\(logoFileName)")
        if FileManager.default.fileExists(atPath: url.path) {
          logoCachedURL = url
        } else {
          logoCachedURL = nil
        }
      } else {
        logoCachedURL = nil
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

    /// Lowercase name used in cosntructing the topic's url.
    public let name: String
    /// Formal name used in titles.
    public let displayName: String
    /// Equivalent tags
    public let aliases: String?
    public let related: String?

    public let logoCachedURL: URL?

    public let creator: String?
    public let releaseDate: Date?

    /// Short description.
    public let summary: String
    /// Longer description, markdown syntax allowed.
    public let description: String

    public let url: URL?
    public let githubURL: URL?
    public let wikipediaURL: URL?
  }

}

// MARK: - YAML Representation

private extension Explore.CuratedTopic {

  /// YAML reprentation in `github/explore`
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
