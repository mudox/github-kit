import Foundation

import Moya

import RxSwift

import JacKit

// MARK: - RawDataResponse

public class RawDataResponse: ResponseType, CustomReflectable {

  public let moyaResponse: Moya.Response
  public let rateLimit: HeaderRateLimit
  public let payload: Data

  public required init(response: Moya.Response) throws {
    moyaResponse = response
    try rateLimit = RawDataResponse.rateLimit(from: response)
    payload = response.data
  }

  public var customMirror: Mirror {
    return Mirror(
      self,
      children: [
        "status": "\(Jack.description(ofHTTPStatusCode: moyaResponse.statusCode))",
        "rate limit": rateLimit,
        "raw data": payload,
      ],
      displayStyle: .class
    )
  }
}
