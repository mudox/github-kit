import Moya
import Result

import JacKit

public class LoggingPlugin: PluginType {

  private var isEnabled: Bool {
    return ProcessInfo.processInfo.environment["MOYA_LOGGING_PLUGIN"] == "enable"
  }

  public func willSend(_ request: RequestType, target: TargetType) {
    guard isEnabled else { return }

    let urlRequest = request.request

    Jack("GitHubKit.LoggingPlugin.willSend").debug("""
    \(String(describing: request))
    ---
    \(String(reflecting: request))
    """, format : .noLocation)
  }

  public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
    guard isEnabled else { return }

    Jack("GitHubKit.LoggingPlugin.didReceive").debug("""
    \(dump(of: result))
    """, format: .noLocation)
  }

  private func dump(of result: Result<Moya.Response, MoyaError>) -> String {
    switch result {
    case let .success(response):
      return """
      Result.success
      \(self.dump(of: response))
      """
    case let .failure(error):
      return """
      Result.failure
      \(JacKit.dump(of: error))
      """
    }
  }

  private func dump(of response: Moya.Response) -> String {
    let headers: String
    if
      let urlResponse = response.response,
      let fields = urlResponse.allHeaderFields as? [String: String]
    {
      headers = fields
        .map { "  \($0): \($1)" }
        .joined(separator: "\n")
    } else {
      headers = "<nil>"
    }

    let status = "\(response.statusCode) \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))"

    return """
    HTTPURLResponse
    - status code: \(status)
    - url: \(response.response?.url?.absoluteString ?? "<nil>")
    - headers: \(headers)
    - data: \(response.data.count) bytes
    """
  }

}
