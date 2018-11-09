import Moya

import JacKit

private let jack = Jack("GitHub.AuthPlugin").set(options: .short)

public class AuthPlugin: PluginType {

  private let credentials: CredentialServiceType

  public init(credentialService: CredentialServiceType) {
    self.credentials = credentialService
  }

  // MARK: - PluginType

  public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
    guard let target = target as? APIv3 else {
      jack.descendant("prepare").warn("the target type is not `GitHub.APIv3`")
      return request
    }

    var request = request

    switch target.authenticationType {
    case .none:
      break
    case .user:
      guard let (name, password) = credentials.user else {
        jack.warn("username & password is missing")
        return request
      }
      let field = Headers.Authorization.user(name: name, password: password)
      request.setValue(field, forHTTPHeaderField: "Authorization")
    case .app:
      guard let (key, secret) = credentials.app else {
        jack.warn("app key & secret is missing")
        return request
      }
      let field = Headers.Authorization.app(key: key, secret: secret)
      request.setValue(field, forHTTPHeaderField: "Authorization")
    case .token:
      guard let token = credentials.token else {
        jack.warn("access token is missing")
        return request
      }
      request.setValue(token, forHTTPHeaderField: "Authorization")
    }

    return request
  }
}
