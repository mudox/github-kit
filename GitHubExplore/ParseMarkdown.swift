import Foundation

import Yams

import JacKit

internal extension GitHubExplore {

  /// Parse the **index.md** markdown files from github/explore repository.
  ///
  /// - Parameter text: String content of the **index.md** file.
  /// - Returns: A tuple of YAML document string and the longer description string.
  /// - Throws: `NSError` thrown by initializing `NSRegularExpression`
  func parse(text: String) throws -> (yamlString: String, description: String) {
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

}
