import Foundation

import Yams

import JacKit

public extension Explore {

  struct Collection {

    // swiftlint:disable:next nesting
    enum Error: Swift.Error {
      case regexMatch
    }

    /// Initialize an instance of CuratedTopic from an index.md file from github/explore repository.
    ///
    /// - Parameter url: URL of the index.md file.
    public init(yamlString: String, description: String) throws {

      let decoder = YAMLDecoder()
      let decoded = try decoder.decode(_YAML.self, from: yamlString)

      items = decoded.items
      creator = decoded.created_by
      displayName = decoded.display_name
      self.description = description
    }

    let items: [String]
    let creator: String?
    let displayName: String
    let description: String

  }

}

// MARK: - YAML Representation

fileprivate extension Explore.Collection {

  /// YAML reprentation in `github/explore`
  struct _YAML: Decodable {
    // swiftlint:disable identifier_name
    let items: [String]
    let created_by: String?
    let display_name: String
    // swiftlint:enable identifier_name
  }

}
