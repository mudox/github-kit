import Foundation

public struct Tree: Decodable {
  public let sha: String
  public let truncated: Bool
  public let members: [Member]
}

public extension Tree {

  struct Member: Decodable {
    public let sha: String
    public let path: String
    public let type: GitObjectType
    public let mode: String
  }

}
