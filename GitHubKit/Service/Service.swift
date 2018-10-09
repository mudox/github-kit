import Foundation

import Moya

public class Service {

  public let authPlugin: AuthPlugin
  public let loggingPlugin: LoggingPlugin

  public let provider: MoyaProvider<GitHubAPIv3>

  public init(authPlugin: AuthPlugin) {
    self.authPlugin = authPlugin
    loggingPlugin = LoggingPlugin()

    provider = MoyaProvider<GitHubAPIv3>(
      plugins: [authPlugin, loggingPlugin]
    )
  }

}
