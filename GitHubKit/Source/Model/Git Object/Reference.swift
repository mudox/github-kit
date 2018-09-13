import Foundation

public enum GitObjectType: String, Decodable {
  case reference
  case commit
  case tree
  case blob
}

public struct Reference: Decodable {
  public let path: String
  public let target: Target

  private enum CodingKeys: String, CodingKey {
    case path = "ref"
    case target = "object"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    path = try container.decode(String.self, forKey: .path)
    target = try container.decode(Target.self, forKey: .target)

  }
}

public extension Reference {

  struct Target: Decodable {
    public let sha: String
    public let type: GitObjectType
  }

}
