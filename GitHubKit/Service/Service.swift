import Foundation

import Moya

public class Service {

  /// Use it when you need non-FRP interface.
  public let provider: MoyaProvider<APIv3>

  /// Storage object to get and store credentials needed by service.
  public let credentials: CredentialServiceType

  private let authPlugin: AuthPlugin
  private let loggingPlugin: LoggingPlugin

  public init(credentialService: CredentialServiceType) {
    credentials = credentialService

    authPlugin = AuthPlugin(credentialService: credentialService)
    loggingPlugin = LoggingPlugin()

    provider = MoyaProvider<APIv3>(
      plugins: [authPlugin, loggingPlugin]
    )
  }

}

// MARK: - GitHub.Service.Error

public extension Service {

  enum Error: Swift.Error {
    case invalidParameter(String)
  }

}
