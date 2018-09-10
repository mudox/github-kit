import Foundation

public struct App: Decodable {

  public let name: String
  public let url: URL
  public let clientID: String

  private enum CodingKeys: String, CodingKey {
    case name
    case url
    case clientID = "client_id"
  }

}
