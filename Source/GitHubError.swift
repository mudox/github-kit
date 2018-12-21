import Foundation

import Alamofire
import Moya

import JacKit

/// GitHubError
public enum GitHubError: Swift.Error {
  // Moya.Response.response: HTTPURLResponse? return nil
  case noHTTPURLResponse

  // General casting error
  case casting(from: Any?, to: Any.Type)

  // Parsing rate limit information from response header failed
  case initRateLimit(headers: [String: String])

  // Parsing pagination information from response header failed
  case initPagination(headers: [String: String])

  // Before authorize, necessary credentials must be present.
  case missingCredential(String)

  // HTTP 401 Unauthorized
  // Invalid username & password, or access token, app key & secret in
  // `Authorization` header field
  case invalidCredential(ErrorMessage?)

  // HTTP 422 Unprocessable Entity
  // Invalid request paramter in request message
  case invalidRequestParameter(ErrorMessage?)
}

/// Parse the general `Swift.Error` instance, return `GitHub.Error` if
/// applicable.
///
/// - Parameter error: The `Swift.Error` instance.
/// - Returns: The resultant `GitHub.Error` if applicable, otherwise the
///   original error instance.
internal func elevate(error: Swift.Error) -> Swift.Error {
  switch error {
  case let MoyaError.underlying(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code)), response):
    switch code {
    case 401:
      return GitHubError.invalidCredential(ErrorMessage(response: response))
    case 422:
      return GitHubError.invalidRequestParameter(ErrorMessage(response: response))
    default:
      return error
    }
  default:
    return error
  }
}

public struct ErrorMessage: Decodable {

  init?(response: Moya.Response?) {
    let jack = Jack("GitHubKit.ErrorMessage.init")

    guard let response = response else {
      jack.error("response is nil")
      return nil
    }

    do {
      self = try JSONDecoder().decode(ErrorMessage.self, from: response.data)
    } catch {
      jack.error("error JSON decoding: \(error)")
      return nil
    }
  }

  public struct Error: Decodable {
    public let resource: String?
    public let code: String?
    public let field: String?
    public let message: String?
  }

  public let message: String
  public let documentationURL: URL?
  public let errors: [Error]?

  private enum CodingKeys: String, CodingKey {
    case message
    case documentationURL = "documentation_url"
    case errors
  }

}
