import Foundation

import Moya

public class Service {

  public let credentialService: CredentialServiceType
  public let authPlugin: AuthPlugin
  public let loggingPlugin: LoggingPlugin

  public let provider: MoyaProvider<APIv3>

  public init(credentialService: CredentialServiceType) {
    self.credentialService = credentialService

    authPlugin = AuthPlugin(credentialService: credentialService)
    loggingPlugin = LoggingPlugin()

    provider = MoyaProvider<APIv3>(
      plugins: [authPlugin, loggingPlugin]
    )
  }

}

public extension Service {

  enum Error: Swift.Error {
    case invalidParameter(String)
  }

}
