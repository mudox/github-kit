import Moya

enum MoyaTarget {

  // MARK: Search

  case searchRepository(String)

  // MARK: User

  case currentUser
  case user(name: String)

  // MARK: Misc

  case zen
  case rateLimit

  // MARK: Authorization

  case authorize
  case deleteAuthorization(id: Int)
  case authorizations

  // MARK: Grant

  case grants
  case deleteGrant(id: Int)

  // MARK: Data

  case reference(ownerName: String, repositoryName: String, path: String)
  case commit(ownerName: String, repositoryName: String, sha: String)
  case tree(ownerName: String, repositoryName: String, sha: String)
  case blob(ownerName: String, repositoryName: String, sha: String)

  // MARK: Follower

  case followers(username: String)
  case isFollowing(username: String, targetUsername: String)
//  case follow(username: String)
//  case unfollow(username: String)

}

extension MoyaTarget: Moya.TargetType {
  public var method: Moya.Method {
    switch self {
    // Search
    case .searchRepository:
      return .get

    // User
    case .user, .currentUser:
      return .get

    // Misc
    case .zen, .rateLimit:
      return .get

    // Auhorization
    case .authorizations:
      return .get
    case .authorize:
      return .post
    case .deleteAuthorization:
      return .delete

    // Grant
    case .grants:
      return .get
    case .deleteGrant:
      return .delete

    // Data
    case .reference, .commit, .tree, .blob:
      return .get

    // Follower
    case .followers, .isFollowing:
      return .get
    }

  }

  public var baseURL: URL {
    return URL(string: "https://api.github.com")!
  }

  public var path: String {
    switch self {
    // Search
    case .searchRepository:
      return "/search/repositories"

    // User
    case .currentUser:
      return "/user"
    case let .user(name):
      return "/users/\(name)"

    // Misc
    case .zen:
      return "/zen"
    case .rateLimit:
      return "/rate_limit"

    // Authorization
    case .authorize, .authorizations:
      return "/authorizations"
    case let .deleteAuthorization(id):
      return "/authorizations/\(id)"

    // Grant
    case .grants:
      return "/applications/grants"
    case let .deleteGrant(id):
      return "/applications/grants/\(id)"

    // Data
    case let .reference(ownerName, repositoryName, path):
      return "/repos/\(ownerName)/\(repositoryName)/git/refs/\(path)"
    case let .commit(ownerName, repositoryName, sha):
      return "/repos/\(ownerName)/\(repositoryName)/git/commits/\(sha)"
    case let .tree(ownerName, repositoryName, sha):
      return "/repos/\(ownerName)/\(repositoryName)/git/trees/\(sha)"
    case let .blob(ownerName, repositoryName, sha):
      return "/repos/\(ownerName)/\(repositoryName)/git/blobs/\(sha)"

      // Follower

    case let .followers(username):
      return "/users/\(username)/followers"
    case let .isFollowing(username, targetUsername):
      return "/users/\(username)/following/\(targetUsername)"
    }
  }

  public var headers: [String: String]? {
    switch self {
    // Search
    case .searchRepository:
      return Dev.defaultTokenHeaders

    // User
    case .user, .currentUser:
      return Dev.defaultTokenHeaders

    // Misc
    case .zen:
      return Dev.defaultTokenHeaders
    case .rateLimit:
      return Dev.defaultMudoxAuthHeaders

    // Authorization
    case .authorize, .deleteAuthorization, .authorizations:
      return Dev.defaultMudoxAuthHeaders

    // Grant
    case .grants, .deleteGrant:
      return Dev.defaultMudoxAuthHeaders

    // Data
    case .reference, .commit, .tree, .blob:
      return Dev.defaultTokenHeaders

    // Follower
    case .followers, .isFollowing:
      return Dev.defaultTokenHeaders
    }

  }

  public var task: Task {
    switch self {

    // Search
    case let .searchRepository(query):
      let parameters: [String: Any] = [
        "q": query,
        "sort": "stars",
        "order": "desc"
      ]
      return .requestParameters(parameters: parameters, encoding: URLEncoding.default)

    // User
    case .user, .currentUser:
      return .requestPlain

    // Misc
    case .zen, .rateLimit:
      return .requestPlain

    // Authorization
    case .authorize:
      let param: [String: Any] = [
        "note": "Test Service.authorize",
        "client_id": Dev.clientID,
        "client_secret": Dev.clientSecret,
        "scopes": [
          "user",
          "repo",
          "admin:org",
          "notifications"
        ]
      ]
      return .requestParameters(parameters: param, encoding: JSONEncoding.default)
    case .deleteAuthorization, .authorizations:
      return .requestPlain

    // Grant
    case .grants, .deleteGrant:
      return .requestPlain

    // Data
    case .reference, .commit, .tree, .blob:
      return .requestPlain

    // Follower
    case .followers, .isFollowing:
      return .requestPlain
    }

  }

  public var validationType: ValidationType {
    switch self {
    case .isFollowing:
      // See https://developer.github.com/v3/users/followers/#check-if-one-user-follows-another
      // This endpoint return 202 as true, 404 as false
      return .none
    default:
      return .successCodes
    }
  }

  public var sampleData: Data {
    return Data()
  }
}
