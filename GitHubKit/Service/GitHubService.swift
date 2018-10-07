import Foundation

import Moya

public struct GitHubService {

  public let provider = MoyaProvider<MoyaTarget>().rx
  
  public init() {}

}
