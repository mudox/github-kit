import Moya

import JacKit

private let jack = Jack("GitHub.AuthPlugin").set(options: .short)

public protocol CredentialServiceType: AnyObject {
  var token: String? { get set }
  var user: (name: String, password: String)? { get set }
  var app: (key: String, secret: String)? { get set }
}

public class AuthPlugin: PluginType {

  private let credentialService: CredentialServiceType

  public init(credentialService: CredentialServiceType) {
    self.credentialService = credentialService
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
      guard let (name, password) = credentialService.user else {
        jack.warn("username & password is missing")
        return request
      }
      let field = Headers.Authorization.user(name: name, password: password)
      request.setValue(field, forHTTPHeaderField: "Authorization")
    case .app:
      guard let (key, secret) = credentialService.app else {
        jack.warn("app key & secret is missing")
        return request
      }
      let field = Headers.Authorization.app(key: key, secret: secret)
      request.setValue(field, forHTTPHeaderField: "Authorization")
    case .token:
      guard let token = credentialService.token else {
        jack.warn("access token is missing")
        return request
      }
      request.setValue(token, forHTTPHeaderField: "Authorization")
    }

    return request
  }
}
