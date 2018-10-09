import Moya

import JacKit

public class AuthPlugin: PluginType {

  public var token: String?
  public var user: (name: String, password: String)?
  public var app: (key: String, secret: String)?

  public init(
    token: String? = nil,
    user: (name: String, password: String)? = nil,
    app: (key: String, secret: String)? = nil
  ) {
    self.token = token
    self.user = user
    self.app = app
  }

  public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
    guard let target = target as? GitHubAPIv3 else {
      Jack("GitHubKit.AuthenticationPlugin").warn(
        "the target type is not `GitHubKit.GitHubAPIv3`", options: .short
      )
      return request
    }

    var request = request

    switch target.authenticationType {
    case .none:
      break
    case .user:
      guard let (name, password) = user else {
        return request
      }
      let field = Headers.Authorization.user(name: name, password: password)
      request.setValue(field, forHTTPHeaderField: "Authorization")
    case .app:
      guard let (key, secret) = app else {
        return request
      }
      let field = Headers.Authorization.app(key: key, secret: secret)
      request.setValue(field, forHTTPHeaderField: "Authorization")
    case .token:
      guard let (name, password) = user else {
        return request
      }
      let field = Headers.Authorization.user(name: name, password: password)
      request.setValue(field, forHTTPHeaderField: "Authorization")
    }

    return request
  }
}
