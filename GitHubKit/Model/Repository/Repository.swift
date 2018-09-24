import Foundation

public struct Repository: Decodable {
  /// Sorting ranking score, only for repository items returned from GitHub
  /// search endpoints.
  public let score: Double?

  public let id: Int
  public let name: String
  public let fullName: String
  public let owner: Owner
  public let purplePrivate: Bool
  public let description: String?
  public let isFork: Bool

  public let creationDate: Date
  public let updateDate: Date
  public let pushDate: Date

  public let homepage: String?

  // Counts
  public let forksCount: Int
  public let openIssuesCount: Int
  public let stargazersCount: Int
  public let watchersCount: Int

  // Only available for GitHub listing authenticated user's repositories
  // endpoint.
  public let subscribersCount: Int?
  public let networksCount: Int?

  public let size: Int

  public let language: String?
  public let hasIssues: Bool
  public let hasProjects: Bool
  public let hasDownloads: Bool
  public let hasWiki: Bool
  public let hasPages: Bool
  public let archived: Bool
  public let license: License?
  public let defaultBranch: String
  public let permissions: Permissions?

  private enum CodingKeys: String, CodingKey {
    case archived
    case creationDate = "created_at"
    case defaultBranch = "default_branch"
    case description
    case forksCount = "forks_count"
    case fullName = "full_name"
    case hasDownloads = "has_downloads"
    case hasIssues = "has_issues"
    case hasPages = "has_pages"
    case hasProjects = "has_projects"
    case hasWiki = "has_wiki"
    case homepage
    case id
    case isFork = "fork"
    case language
    case license
    case name
    case openIssuesCount = "open_issues_count"
    case owner
    case permissions
    case purplePrivate = "private"
    case pushDate = "pushed_at"
    case score
    case size
    case stargazersCount = "stargazers_count"
    case updateDate = "updated_at"
    case watchersCount = "watchers"
    case subscribersCount = "subscribers_count"
    case networksCount = "network_count"
  }

  // swiftlint:disable:next function_body_length
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    // swiftformat:disable consecutiveSpaces
    // swiftlint:disable operator_usage_whitespace comma
    archived         = try container.decode(Bool.self,                 forKey: .archived)
    defaultBranch    = try container.decode(String.self,               forKey: .defaultBranch)
    description      = try container.decodeIfPresent(String.self,      forKey: .description)
    forksCount       = try container.decode(Int.self,                  forKey: .forksCount)
    fullName         = try container.decode(String.self,               forKey: .fullName)
    hasDownloads     = try container.decode(Bool.self,                 forKey: .hasDownloads)
    hasIssues        = try container.decode(Bool.self,                 forKey: .hasIssues)
    hasPages         = try container.decode(Bool.self,                 forKey: .hasPages)
    hasProjects      = try container.decode(Bool.self,                 forKey: .hasProjects)
    hasWiki          = try container.decode(Bool.self,                 forKey: .hasWiki)
    homepage         = try container.decodeIfPresent(String.self,      forKey: .homepage)
    id               = try container.decode(Int.self,                  forKey: .id)
    isFork           = try container.decode(Bool.self,                 forKey: .isFork)
    language         = try container.decodeIfPresent(String.self,      forKey: .language)
    license          = try container.decodeIfPresent(License.self,     forKey: .license)
    name             = try container.decode(String.self,               forKey: .name)
    networksCount    = try container.decodeIfPresent(Int.self,         forKey: .networksCount)
    openIssuesCount  = try container.decode(Int.self,                  forKey: .openIssuesCount)
    owner            = try container.decode(Owner.self,                forKey: .owner)
    permissions      = try container.decodeIfPresent(Permissions.self, forKey: .permissions)
    purplePrivate    = try container.decode(Bool.self,                 forKey: .purplePrivate)
    score            = try container.decodeIfPresent(Double.self,      forKey: .score)
    size             = try container.decode(Int.self,                  forKey: .size)
    stargazersCount  = try container.decode(Int.self,                  forKey: .stargazersCount)
    subscribersCount = try container.decodeIfPresent(Int.self,         forKey: .subscribersCount)
    watchersCount    = try container.decode(Int.self,                  forKey: .watchersCount)
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

    let pushDateString = try container.decode(String.self, forKey: .pushDate)
    guard let pushDate = formatter.date(from: pushDateString) else {
      throw DecodingError.dataCorruptedError(
        forKey: .pushDate, in: container,
        debugDescription: "parsing `.pushDate` as RFC3339 date failed"
      )
    }
    self.pushDate = pushDate
  }

}

public extension Repository {

  // MARK: - Repository.License

  struct License: Decodable {
    let key: String
    let name: String
    let spdxID: String?

    // swiftlint:disable:next nesting
    private enum CodingKeys: String, CodingKey {
      case key
      case name
      case spdxID = "spdx_id"
    }
  }

  // MARK: - Repository.Owner

  struct Owner: Decodable {
    public let login: String
    public let id: Int
    public let avatarURL: URL
    public let type: String
    public let siteAdmin: Bool

    // swiftlint:disable:next nesting
    private enum CodingKeys: String, CodingKey {
      case avatarURL = "avatar_url"
      case id
      case login
      case siteAdmin = "site_admin"
      case type
    }
  }

  // MARK: - Repository.Permission

  struct Permissions: Codable {
    public let admin: Bool
    public let push: Bool
    public let pull: Bool
  }
}
