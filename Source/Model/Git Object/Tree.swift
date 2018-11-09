import Foundation

public struct Tree: Decodable {
  public let sha: String
  public let truncated: Bool
  public let members: [Node]

  private enum CodingKeys: String, CodingKey {
    case sha
    case truncated
    case members = "tree"
  }

}

public extension Tree {

  struct Node: Decodable {
    public let sha: String
    public let path: String
    public let type: String
    public let mode: String
  }

}
