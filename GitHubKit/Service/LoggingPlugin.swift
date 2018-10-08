import Moya
import Result

import JacKit

public class LoggingPlugin: PluginType {

  public func willSend(_ request: RequestType, target: TargetType) {
    let urlRequest = request.request

    Jack("GitHubKit.LoggingPlugin.willSend").debug("""
    \(Jack.dump(of: request))
    """, options: .noLocation)
  }

  public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
    Jack("GitHubKit.LoggingPlugin.didReceive").debug("""
    \(Jack.dump(of: result))
    """, options: .noLocation)
  }

}
