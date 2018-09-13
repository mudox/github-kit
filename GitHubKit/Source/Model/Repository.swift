import Foundation

public struct Repository: Decodable {
  public let id: Int
  public let nodeID: String
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
  public let stargazersCount: Int
  public let watchersCount: Int
  public let openIssuesCount: Int
  public let forksCount: Int

  public let size: Int

  public let language: String?
  public let hasIssues: Bool
  public let hasProjects: Bool
  public let hasDownloads: Bool
  public let hasWiki: Bool
  public let hasPages: Bool
  public let archived: Bool
  public let license: License?
  public let forks: Int
  public let openIssues: Int
  public let defaultBranch: String
  public let permissions: Permissions?
  public let score: Double

  private enum CodingKeys: String, CodingKey {
    case archived
    case creationDate = "created_at"
    case defaultBranch = "default_branch"
    case description
    case forks
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
    case nodeID = "node_id"
    case openIssues = "open_issues"
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
  }

  // swiftlint:disable:next function_body_length
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    archived = try container.decode(Bool.self, forKey: .archived)
    defaultBranch = try container.decode(String.self, forKey: .defaultBranch)
    description = try container.decodeIfPresent(String.self, forKey: .description)
    forks = try container.decode(Int.self, forKey: .forks)
    forksCount = try container.decode(Int.self, forKey: .forksCount)
    fullName = try container.decode(String.self, forKey: .fullName)
    hasDownloads = try container.decode(Bool.self, forKey: .hasDownloads)
    hasIssues = try container.decode(Bool.self, forKey: .hasIssues)
    hasPages = try container.decode(Bool.self, forKey: .hasPages)
    hasProjects = try container.decode(Bool.self, forKey: .hasProjects)
    hasWiki = try container.decode(Bool.self, forKey: .hasWiki)
    homepage = try container.decodeIfPresent(String.self, forKey: .homepage)
    id = try container.decode(Int.self, forKey: .id)
    isFork = try container.decode(Bool.self, forKey: .isFork)
    language = try container.decodeIfPresent(String.self, forKey: .language)
    license = try container.decodeIfPresent(License.self, forKey: .license)
    name = try container.decode(String.self, forKey: .name)
    nodeID = try container.decode(String.self, forKey: .nodeID)
    openIssues = try container.decode(Int.self, forKey: .openIssues)
    openIssuesCount = try container.decode(Int.self, forKey: .openIssuesCount)
    owner = try container.decode(Owner.self, forKey: .owner)
    permissions = try container.decodeIfPresent(Permissions.self, forKey: .permissions)
    purplePrivate = try container.decode(Bool.self, forKey: .purplePrivate)
    score = try container.decode(Double.self, forKey: .score)
    size = try container.decode(Int.self, forKey: .size)
    stargazersCount = try container.decode(Int.self, forKey: .stargazersCount)
    watchersCount = try container.decode(Int.self, forKey: .watchersCount)

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
