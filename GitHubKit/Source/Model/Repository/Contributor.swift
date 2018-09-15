import Foundation

public struct Contributor: Decodable {
  public let loginName: String
  public let id: Int
  public let type: String
  public let isSiteAdmin: Bool
  public let contributionsCount: Int

  private enum CodingKeys: String, CodingKey {
    case loginName = "login"
    case id
    case type
    case isSiteAdmin = "site_admin"
    case contributionsCount = "contributions"
  }

}
