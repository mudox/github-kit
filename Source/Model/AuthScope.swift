public struct AuthScope: OptionSet {
  // MARK: - SetAlgebra

  public mutating func formUnion(_ other: AuthScope) {
    rawValue.formUnion(other.rawValue)
  }

  public mutating func formIntersection(_ other: AuthScope) {
    rawValue.formIntersection(other.rawValue)
  }

  public mutating func formSymmetricDifference(_ other: AuthScope) {
    rawValue.formSymmetricDifference(other.rawValue)
  }

  public init() {
    rawValue = []
  }

  // MARK: - RawRepresentable

  public var rawValue: Set<String>

  public init(rawValue: Set<String>) {
    self.rawValue = rawValue
  }

  // MARK: - Scopes

  // See https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/

  /// Grants read/write access to code, commit statuses, invitations,
  /// collaborators, adding team memberships, and deployment statuses for public
  /// and private repositories and organizations.
  public static let repository = AuthScope(rawValue: ["repo"])
  /// Grants read/write access to public and private repository commit statuses.
  /// This scope is only necessary to grant other users or services access to
  /// private repository commit statuses without granting access to the code.
  public static let repositoryStatus = AuthScope(rawValue: ["repo:status"])
  /// Grants access to deployment statuses for public and private repositories.
  /// This scope is only necessary to grant other users or services access to
  /// deployment statuses, without granting access to the code.
  public static let repositoryDeployment = AuthScope(rawValue: ["repo_deployment"])
  /// Grants read/write access to code, commit statuses, collaborators, and
  /// deployment statuses for public repositories and organizations. Also required
  /// for starring public repositories.
  public static let publicRepository = AuthScope(rawValue: ["public_repo"])
  /// Grants accept/decline abilities for invitations to collaborate on a
  /// repository. This scope is only necessary to grant other users or services
  /// access to invites without granting access to the code.
  public static let invitation = AuthScope(rawValue: ["repo:invite"])

  /// Fully manage organization, teams, and memberships.
  public static let organization = AuthScope(rawValue: ["admin:org"])
  /// Publicize and unpublicize organization membership.
  public static let writeOrganization = AuthScope(rawValue: ["write:org"])
  /// Read-only access to organization, teams, and membership.
  public static let readOrganization = AuthScope(rawValue: ["read:org"])

  /// Fully manage public keys.
  public static let publicKey = AuthScope(rawValue: ["public_key"])
  /// Create, list, and view details for public keys.
  public static let writePublicKey = AuthScope(rawValue: ["write:public_key"])
  /// List and view details for public keys.
  public static let readPublicKey = AuthScope(rawValue: ["read:public_key"])

  /// Grants read, write, ping, and delete access to hooks in public or private
  /// repositories.
  public static let repositoryHook = AuthScope(rawValue: ["admin:repo_hook"])
  /// Grants read, write, and ping access to hooks in public or private
  /// repositories.
  public static let writeRepositoryHook = AuthScope(rawValue: ["write:repo_hook"])
  /// Grants read and ping access to hooks in public or private repositories.
  public static let readRepositoryHook = AuthScope(rawValue: ["read:repo_hook"])

  /// Grants read, write, ping, and delete access to organization hooks.
  ///
  /// - Note:
  /// OAuth tokens will only be able to perform these actions on organization
  /// hooks which were created by the OAuth App. Personal access tokens will only
  /// be able to perform these actions on organization hooks created by a user.
  public static let organizationHook = AuthScope(rawValue: ["admin:org_hook"])

  /// Grants write access to gists.
  public static let gist = AuthScope(rawValue: ["gist"])

  /// Grants read access to a user's notifications. repo also provides this access.
  public static let notification = AuthScope(rawValue: ["notifications"])

  /// Grants read/write access to profile info only. Note that this scope
  /// includes user:email and user:follow.
  public static let user = AuthScope(rawValue: ["user"])
  /// Grants access to read a user's profile data.
  public static let userProfile = AuthScope(rawValue: ["read:user"])
  /// Grants read access to a user's email addresses.
  public static let userEmail = AuthScope(rawValue: ["user:email"])
  /// Grants access to follow or unfollow other users.
  public static let follow = AuthScope(rawValue: ["user:follow"])

  /// Grants access to delete adminable repositories.
  public static let deleteRepository = AuthScope(rawValue: ["delete_repo"])

  /// Allows read and write access for team discussions.
  public static let discussion = AuthScope(rawValue: ["write:discussion"])
  /// Allows read access for team discussions.
  public static let readDiscussion = AuthScope(rawValue: ["read:discussion"])

  /// Fully manage GPG keys.
  public static let gpgKey = AuthScope(rawValue: ["admin:gpg_key"])
  /// Create, list, and view details for GPG keys.
  public static let readGPGKey = AuthScope(rawValue: ["read:gpg_key"])
  /// List and view details for GPG keys.
  public static let writeGPGKey = AuthScope(rawValue: ["write:gpg_key"])
}
