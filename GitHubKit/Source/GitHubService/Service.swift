import Foundation

import Moya

public struct Service {

  // MARK: - Singleton

  public static let shared = Service()

  private init() {}

  // MARK: - MoyaProvider

  public let provider = MoyaProvider<MoyaTarget>().rx

}
