import Foundation

public class PublicUserProfile: Decodable {

  @available(*, unavailable)
  private init() {
    fatalError("make compiler happy")
  }

  // MARK: - Basic Info

  public let id: Int

  public let name: String
  public let loginName: String

  public let bio: String
  public let blog: String?

  public let company: String?
  public let hireable: Bool

  public let email: String?
  public let location: String?

  public let avatarURL: URL?

  public let type: String

  public let creationDate: Date
  public let updateDate: Date

  // MARK: - Counts

  public let publicRepoCount: Int
  public let publicGistCount: Int
  public let followerCount: Int
  public let followingCount: Int

  private enum CodingKeys: String, CodingKey {
    case avatarURL = "avatar_url"
    case bio
    case blog
    case company
    case creationDate = "created_at"
    case email
    case followerCount = "followers"
    case followingCount = "following"
    case hireable
    case id
    case location
    case loginName = "login"
    case name
    case publicGistCount = "public_gists"
    case publicRepoCount = "public_repos"
    case type
    case updateDate = "updated_at"
  }

  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    // swiftformat:disable consecutiveSpaces
    // swiftlint:disable operator_usage_whitespace comma
    avatarURL       = try container.decodeIfPresent(URL.self,    forKey: .avatarURL)
    bio             = try container.decode(String.self, forKey: .bio)
    blog            = try container.decodeIfPresent(String.self, forKey: .blog)
    company         = try container.decodeIfPresent(String.self, forKey: .company)
    email           = try container.decodeIfPresent(String.self, forKey: .email)
    followerCount   = try container.decode(Int.self,    forKey: .followerCount)
    followingCount  = try container.decode(Int.self,    forKey: .followingCount)
    hireable        = try container.decode(Bool.self,   forKey: .hireable)
    id              = try container.decode(Int.self,    forKey: .id)
    location        = try container.decodeIfPresent(String.self, forKey: .location)
    loginName       = try container.decode(String.self, forKey: .loginName)
    name            = try container.decode(String.self, forKey: .name)
    publicGistCount = try container.decode(Int.self,    forKey: .publicGistCount)
    publicRepoCount = try container.decode(Int.self,    forKey: .publicRepoCount)
    type            = try container.decode(String.self, forKey: .type)
    // swiftlint:enable operator_usage_whitespace comma
    // swiftformat:enable consecutiveSpaces

    // Custom date decoding as RFC3339 format
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")

    let creationDateString = try container.decode(String.self, forKey: .creationDate)
    guard let creationDate = formatter.date(from: creationDateString) else {
      throw DecodingError.dataCorruptedError(
        forKey: .creationDate, in: container,
        debugDescription: "parsing `.creationDate` as RFC3339 date failed"
      )
    }
    self.creationDate = creationDate

    let updateDateString = try container.decode(String.self, forKey: .updateDate)
    guard let updateDate = formatter.date(from: updateDateString) else {
      throw DecodingError.dataCorruptedError(
        forKey: .updateDate, in: container,
        debugDescription: "parsing `.updateDate` as RFC3339 date failed"
      )
    }
    self.updateDate = updateDate
  }

}
