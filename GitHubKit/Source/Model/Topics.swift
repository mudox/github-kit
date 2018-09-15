import Foundation

/// Repository topics
///
/// - Note: The topics property for repositories on GitHub is currently
/// available for developers to preview.
public struct Topics: Decodable {
  let names: [String]
}
