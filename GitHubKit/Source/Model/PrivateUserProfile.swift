import Foundation

public class PrivateUserProfile: PublicUserProfile {
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

  // swiftlint:disable nesting
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
