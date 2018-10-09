import Foundation

import Moya

public class Service {

  public let authPlugin: AuthPlugin
  public let loggingPlugin: LoggingPlugin

  public let provider: MoyaProvider<APIv3>

  public init(authPlugin: AuthPlugin) {
    self.authPlugin = authPlugin
    loggingPlugin = LoggingPlugin()

    provider = MoyaProvider<APIv3>(
      plugins: [authPlugin, loggingPlugin]
    )
  }

}
