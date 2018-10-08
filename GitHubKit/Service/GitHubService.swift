import Foundation

import Moya

public class GitHubService {

  public let accessToken: String
  public let provider: MoyaProvider<GitHubAPIv3>

  public init(accessToken: String) {
    self.accessToken = accessToken
    provider = MoyaProvider<GitHubAPIv3>()
  }

}
