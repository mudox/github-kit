import Foundation

public class User: Decodable {
  // TODO: remove it when Swift 4.2 fixed the `no initializer` issue.
  @available(*, deprecated, message: "Do not use.")
  private init() {
    fatalError("Swift 4.1")
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
  public let gravatarID: String?

  public let type: String
  public let isSiteAdmin: Bool

  public let creationDate: String
  public let updateDate: String

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
    case gravatarID = "gravatar_id"
    case hireable
    case id
    case isSiteAdmin = "site_admin"
    case location
    case loginName = "login"
    case name
    case publicGistCount = "public_gists"
    case publicRepoCount = "public_repos"
    case type
    case updateDate = "updated_at"
  }
}

// MARK: - SignedInUser

public class SignedInUser: User {
  public let collaboratorCount: Int
  public let privateGistCount: Int
  public let privateRepoCount: Int
  public let ownedPrivateRepoCount: Int

  public let diskUsage: Int
  public let is2FAEnabled: Bool?

  public let plan: Plan

  private enum CodingKeys: String, CodingKey {
    case collaboratorCount = "collaborators"
    case diskUsage = "disk_usage"
    case ownedPrivateRepoCount = "owned_private_repos"
    case plan
    case privateGistCount = "private_gists"
    case privateRepoCount = "total_private_repos"
    case is2FAEnabled = "two_factor_authentication"
  }

  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    collaboratorCount = try container.decode(Int.self, forKey: .collaboratorCount)
    privateGistCount = try container.decode(Int.self, forKey: .privateGistCount)
    privateRepoCount = try container.decode(Int.self, forKey: .privateRepoCount)
    ownedPrivateRepoCount = try container.decode(Int.self, forKey: .ownedPrivateRepoCount)

    diskUsage = try container.decode(Int.self, forKey: .diskUsage)
    is2FAEnabled = try container.decode(Bool.self, forKey: .is2FAEnabled)

    plan = try container.decode(Plan.self, forKey: .plan)

    try super.init(from: decoder)
  }

  public struct Plan: Decodable {
    public let collaborators: Int
    public let name: String
    public let privateRepos: Int
    public let space: Int

    private enum CodingKeys: String, CodingKey {
      case collaborators
      case name
      case privateRepos = "private_repos"
      case space
    }
  }
}
