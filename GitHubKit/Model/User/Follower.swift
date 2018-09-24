import Foundation

public struct Follower: Decodable {

  let id: Int
  let loginName: String
  let type: String

  private enum CodingKeys: String, CodingKey {
    case id
    case loginName = "login"
    case type
  }

}
