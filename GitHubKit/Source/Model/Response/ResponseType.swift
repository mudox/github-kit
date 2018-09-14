import Foundation

import Moya

protocol ResponseType {
  /// Add convenient initiailizer that enables syntax like
  ///
  ///     return provider.request(...)
  ///       .map(CommitResponse.init)
  ///
  init(response: Moya.Response) throws

  var moyaResponse: Moya.Response { get }

  var rateLimit: HeaderRateLimit { get }

  associatedtype Payload

  var payload: Payload { get }
}

internal extension ResponseType {

  static func rateLimit(from response: Moya.Response) throws -> HeaderRateLimit {
    guard let urlResponse = response.response else {
      throw Error.noHTTPURLResponse
    }

    guard let headers = urlResponse.allHeaderFields as? [String: String] else {
      throw Error.casting(from: urlResponse.allHeaderFields, to: [String: String].self)
    }

    guard let rateLimit = HeaderRateLimit(from: headers) else {
      throw Error.initRateLimit(headers: headers)
    }

    return rateLimit
  }

}
