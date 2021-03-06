import Foundation

import Alamofire
import Moya

import RxSwift

import JacKit

// MARK: - RawDataResponse

public class IsFollowingResponse: ResponseType, CustomReflectable {

  public let moyaResponse: Moya.Response
  public let rateLimit: HeaderRateLimit
  public let payload: Bool

  public required init(response: Moya.Response) throws {
    moyaResponse = response

    try rateLimit = RawDataResponse.rateLimit(from: response)

    switch response.statusCode {
    case 204:
      payload = true
    case 404:
      payload = false
    default:
      throw AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: response.statusCode))
    }
  }

  public var customMirror: Mirror {
    return Mirror(
      self,
      children: [
        "status": "\(string(fromHTTPStatusCode: moyaResponse.statusCode))",
        "rate limit": rateLimit,
        "is following": payload
      ],
      displayStyle: .class
    )
  }
}
