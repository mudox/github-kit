import Moya

import JacKit

public class AuthPlugin: PluginType {

  public var token: String?
  public var user: (name: String, password: String)?
  public var app: (key: String, secret: String)?

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
      request.setValue(field, forHTTPHeaderField: "Accept")
    case .app:
      guard let (key, secret) = app else {
        return request
      }
      let field = Headers.Authorization.app(key: key, secret: secret)
      request.setValue(field, forHTTPHeaderField: "Accept")
    case .token:
      guard let (name, password) = user else {
        return request
      }
      let field = Headers.Authorization.user(name: name, password: password)
      request.setValue(field, forHTTPHeaderField: "Accept")
    }

    return request
  }
}
