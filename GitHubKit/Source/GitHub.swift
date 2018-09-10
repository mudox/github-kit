import Foundation

import Moya

public enum Payload {}

protocol MoyaResponseConvertible {
  init(response: Moya.Response) throws
}
