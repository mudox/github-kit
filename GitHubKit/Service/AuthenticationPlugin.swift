import Moya

import JacKit

internal struct GitHubAPIv3Target: PluginType {
  func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
    guard let target = target as? GitHubAPIv3 else {
      Jack("GitHubKit.AuthenticationPlugin").warn(
        "the target type is not `GitHubKit.GitHubAPIv3`", options: .short
      )
      return request
    }

    switch target.authenticationType {
    case .none:
      return request
    case .user:
      fatalError("Not yet implemented")
    case .app:
      fatalError("Not yet implemented")
    case .token:
      fatalError("Not yet implemented")
    }

  }
}
