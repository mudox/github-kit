import Foundation
import Moya

import RxSwift

import JacKit

public class Response<Payload>: MoyaResponseConvertible, CustomReflectable
  where Payload: Decodable {

  public let moyaResponse: Moya.Response
  public let rateLimit: HeaderRateLimit
  public let payload: Payload

  public required init(response: Moya.Response) throws {
    moyaResponse = response

    guard let urlResponse = response.response else {
      throw Error.noHTTPURLResponse
    }

    guard let headers = urlResponse.allHeaderFields as? [String: String] else {
      throw Error.casting(from: urlResponse.allHeaderFields, to: [String: String].self)
    }

    guard let rateLimit = HeaderRateLimit(from: headers) else {
      throw Error.initRateLimit(headers: headers)
    }

    self.rateLimit = rateLimit
    payload = try JSONDecoder().decode(Payload.self, from: response.data)
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
    return Mirror(
      self,
      children: [
        "status": "\(Jack.description(ofHTTPStatusCode: moyaResponse.statusCode))",
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

    guard let pagination = Pagination(from: headers) else {
      throw Error.initPagination(headers: headers)
    }

    self.pagination = pagination

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
