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
    case app
    case creationDate = "created_at"
    case fingerprint
    case hashedToken = "hashed_token"
    case id
    case note
    case noteURL = "note_url"
    case scopes
    case token
    case updateDate = "updated_at"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    app = try container.decode(App.self, forKey: .app)
    fingerprint = try container.decodeIfPresent(String.self, forKey: .fingerprint)
    hashedToken = try container.decode(String.self, forKey: .hashedToken)
    id = try container.decode(Int.self, forKey: .id)
    note = try container.decodeIfPresent(String.self, forKey: .note)
    noteURL = try container.decodeIfPresent(URL.self, forKey: .noteURL)
    scopes = try container.decode([String].self, forKey: .scopes)
    token = try container.decode(String.self, forKey: .token)

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
