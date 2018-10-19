import Foundation

import Moya

import RxSwift

import JacKit

// MARK: - Response<Payload>

public class Response<Payload>: ResponseType, CustomReflectable
  where Payload: Decodable {

  public let moyaResponse: Moya.Response
  public let rateLimit: HeaderRateLimit
  public let payload: Payload

  public required init(response: Moya.Response) throws {
    guard let urlResponse = response.response else {
      throw Error.noHTTPURLResponse
    }

    guard let headers = urlResponse.allHeaderFields as? [String: String] else {
      throw Error.casting(from: urlResponse.allHeaderFields, to: [String: String].self)
    }

    guard let rateLimit = HeaderRateLimit(from: headers) else {
      throw Error.initRateLimit(headers: headers)
    }

    let payload = try JSONDecoder().decode(Payload.self, from: response.data)

    moyaResponse = response
    self.rateLimit = rateLimit
    self.payload = payload
  }

  public var statusCode: Int {
    return moyaResponse.statusCode
  }

  public var statusDescription: String {
    let code = statusCode
    let description = HTTPURLResponse.localizedString(forStatusCode: code)
    return "\(code) \(description)"
  }

  public var customMirror: Mirror {
    // Do not expand payload, it may be very long
    return Mirror(
      self,
      children: [
        "status": "\(description(ofHTTPStatusCode: moyaResponse.statusCode))",
        "rate limit": rateLimit,
        "payload type": type(of: payload)
      ],
      displayStyle: .class
    )
  }

}

// MARK: - PagedResponse<Payload>

public class PagedResponse<Payload>: Response<Payload>
  where Payload: Decodable {

  public let pagination: Pagination

  public required init(response: Moya.Response) throws {

    guard let urlResponse = response.response else {
      throw Error.noHTTPURLResponse
    }

    guard let headers = urlResponse.allHeaderFields as? [String: String] else {
      throw Error.casting(from: urlResponse.allHeaderFields, to: [String: String].self)
    }

    self.pagination = try Pagination(from: headers)

    try super.init(response: response)
  }

  public override var customMirror: Mirror {
    return Mirror(
      self,
      children: [
        "pagination": pagination
      ],
      displayStyle: .class,
      ancestorRepresentation: .customized { super.customMirror }
    )
  }

}
