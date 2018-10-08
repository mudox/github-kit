import Foundation

import Moya

public class GitHubService {

  public let auth: AuthPlugin
  public let provider: MoyaProvider<GitHubAPIv3>

  public init(authPlugin: AuthPlugin) {
    self.auth = authPlugin
    provider = MoyaProvider<GitHubAPIv3>(
      plugins: [auth]
    )
  }

}
