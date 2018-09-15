import Foundation

public struct Contributor: Decodable {
  public let login: String
  public let id: Int
  public let type: String
  public let isSiteAdmin: Bool
  public let contributions: Int
}
