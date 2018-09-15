import Foundation

public struct Tag: Decodable {

  public let name: String
  public let commitSHA: String

  private struct Commit: Decodable {
    let sha: String
  }

  private enum CodingKeys: String, CodingKey {
    case name
    case commit
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    name = try container.decode(String.self, forKey: .name)

    let commit = try container.decode(Commit.self, forKey: .commit)
    commitSHA = commit.sha
  }

}
