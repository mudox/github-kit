import Foundation
import Moya


import RxSwift

import Then

public struct Authorization: Decodable {

  public let id: Int
  public let note: String?
  public let noteURL: URL?
  public let scopes: [String]
  public let fingerprint: String?

  public let app: App

  public let token: String
  public let hashedToken: String

  public let creationDate: Date
  public let updateDate: Date

  private enum CodingKeys: String, CodingKey {
    case id
    case app
    case token
    case hashedToken = "hashed_token"
    case note
    case noteURL = "note_url"
    case creationDate = "created_at"
    case updateDate = "updated_at"
    case scopes
    case fingerprint
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    id = try container.decode(Int.self, forKey: .id)
    app = try container.decode(App.self, forKey: .app)
    token = try container.decode(String.self, forKey: .token)
    hashedToken = try container.decode(String.self, forKey: .hashedToken)
    note = try container.decode(String?.self, forKey: .note)
    noteURL = try container.decode(URL?.self, forKey: .noteURL)
    scopes = try container.decode([String].self, forKey: .scopes)
    fingerprint = try container.decode(String?.self, forKey: .fingerprint)

    /*
     *
     * Parse date as RFC3339 date string
     *
     */

    let formatter = DateFormatter().then {
      $0.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
      $0.timeZone = TimeZone(secondsFromGMT: 0)
      $0.locale = Locale(identifier: "en_US_POSIX")
    }

    let creationDateString = try container.decode(String.self, forKey: .creationDate)
    if let date = formatter.date(from: creationDateString) {
      creationDate = date
    } else {
      throw DecodingError.dataCorruptedError(
        forKey: .creationDate, in: container,
        debugDescription: "parsing creation date as RFC3339 date failed"
      )
    }

    let updateDateString = try container.decode(String.self, forKey: .updateDate)
    if let date = formatter.date(from: updateDateString) {
      updateDate = date
    } else {
      throw DecodingError.dataCorruptedError(
        forKey: .updateDate, in: container,
        debugDescription: "parsing update date as RFC3339 date failed"
      )
    }

  } // init(from:) throws

} // struct Authoriztion
