import Foundation

extension GitHub {

  struct App: Decodable {

    let name: String
    let url: URL
    let clientID: String

    private enum CodingKeys: String, CodingKey {
      case name
      case url
      case clientID = "client_id"
    }

  }
  
}
