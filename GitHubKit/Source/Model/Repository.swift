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

  public let creationDate: String
  public let updateDate: String
  public let pushDate: String

  public var homepage: String?

  // Counts
  public let stargazersCount: Int
  public let watchersCount: Int
  public let subscribersCount: Int?

  public let size: Int

  public let language: String?
  public let hasIssues: Bool
  public let hasProjects: Bool
  public let hasDownloads: Bool
  public let hasWiki: Bool
  public let hasPages: Bool
  public let forksCount: Int
  public let archived: Bool
  public let openIssuesCount: Int
  public let license: License?
  public let forks: Int
  public let openIssues: Int
  public let watcherCount: Int
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
    case subscribersCount = "subscribers_count"
    case updateDate = "updated_at"
    case watcherCount = "watchers"
    case watchersCount = "watchers_count"
  }

  // MARK: - Repository.License

  // swiftlint:disable nesting

  public struct License: Decodable {
    let key: String
    let name: String
    let spdxID: String?

    private enum CodingKeys: String, CodingKey {
      case key
      case name
      case spdxID = "spdx_id"
    }
  }

  // MARK: - Repository.Owner

  public struct Owner: Decodable {
    public let login: String
    public let id: Int
    public let avatarURL: URL
    public let type: String
    public let siteAdmin: Bool

    private enum CodingKeys: String, CodingKey {
      case avatarURL = "avatar_url"
      case id
      case login
      case siteAdmin = "site_admin"
      case type
    }
  }

  // MARK: - Repository.Permission

  public struct Permissions: Codable {
    public let admin: Bool
    public let push: Bool
    public let pull: Bool
  }
}
