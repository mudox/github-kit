import Foundation

public struct Tree: Decodable {
  public let sha: String
  public let truncated: Bool
  public let members: [Member]

  private enum CodingKeys: String, CodingKey {
    case sha
    case truncated
    case members = "tree"
  }

}

public extension Tree {

  struct Member: Decodable {
    public let sha: String
    public let path: String
    public let type: GitObjectType
    public let mode: String
  }

}
