import Foundation

import Yams

import JacKit

private func parse(text: String) throws -> (yamlString: String, description: String) {
  let nl = "(?:\\n|\\r\\n|\\r)"

  let pattern = """
  ^
  --- \\s* \(nl)
  (.*)                # YAML
  --- \\s* \(nl)
  (.*)
  $                   # Description
  """

  let regex = try NSRegularExpression(
    pattern: pattern,
    options: [
      .allowCommentsAndWhitespace,
      .dotMatchesLineSeparators,
    ]
  )

  let range = NSRange(text.startIndex ..< text.endIndex, in: text)
  guard let match = regex.firstMatch(in: text, range: range) else {
    throw CuratedTopic.Error.regexMatch
  }

  let nsText = text as NSString
  let yamlString = nsText.substring(with: match.range(at: 1)) as String
  let description = nsText.substring(with: match.range(at: 2)) as String

  return (yamlString, description)
}

public extension GitHubExplore {
  struct CuratedTopic {

    enum Error: Swift.Error {
      case regexMatch
    }

    /// Initialize an instance of CuratedTopic from an index.md file from github/explore repository.
    ///
    /// - Parameter url: URL of the index.md file.
    public init(indexFileURL: URL) throws {

      let text = try String(contentsOf: indexFileURL)
      let (yamlString, desc) = try parse(text: text)

      let decoder = YAMLDecoder()
      let decoded = try decoder.decode(_YAML.self, from: yamlString)

      name = decoded.topic
      displayName = decoded.display_name
      aliases = decoded.aliases
      related = decoded.related

      logoURL = decoded.logo.flatMap(URL.init)

      creator = decoded.created_by

      // Parse release date
      let formatter = DateFormatter()
      formatter.dateFormat = "MMM dd, yyyy"
      releaseDate = decoded.released.flatMap(formatter.date)

      summary = decoded.short_description
      description = desc

      url = decoded.url
      githubURL = decoded.github_url
      wikipediaURL = decoded.wikipedia_url
    }

    /// Lowercase name used in cosntructing the topic's url.
    let name: String
    let displayName: String
    let aliases: String?
    let related: String?

    let logoURL: URL?

    let creator: String?
    let releaseDate: Date?

    /// Short description.
    let summary: String
    /// Longer description, markdown syntax allowed.
    let description: String

    let url: URL?
    let githubURL: URL?
    let wikipediaURL: URL?
  }

}

// MARK: - YAML Representation
fileprivate extension GitHubExplore.CuratedTopic {
  /// YAML reprentation in `github/explore`
  struct _YAML: Decodable {
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
