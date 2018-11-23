import Foundation

import RxAlamofire
import RxSwift

import Kanna

import JacKit

public struct Trending {

  struct HTMLParsingError: Swift.Error {

    init(
      file: StaticString = #file,
      function: StaticString = #function,
      line: UInt = #line
    ) {
      self.file = file.description
      self.function = function.description
      self.line = line
    }

    let reason: String? = nil
    let file: String
    let function: String
    let line: UInt
  }

  public enum Period: String {
    case pastDay = "daily"
    case pastWeek = "weekly"
    case pastMonth = "monthly"
  }

  public enum Category {
    case repository
    case developer
  }

  // MARK: - Private

  fileprivate static func url(of catetory: Category, language: String? = nil, period: Period = .pastDay) -> URL {

    var urlComponents: URLComponents
    switch catetory {
    case .repository:
      urlComponents = URLComponents(string: "https://github.com/trending")!
    case .developer:
      urlComponents = URLComponents(string: "https://github.com/trending/developers")!
    }

    urlComponents.path.append("/\(language)")
    urlComponents.queryItems = [URLQueryItem(name: "since", value: period.rawValue)]

    return urlComponents.url!
  }

  // MARK: - Public

  public init() {}

  /// Request GitHub trending repositories.
  ///
  /// - Note: The `language` can be `all` or `unknown`, if a invalid string is
  ///   given, trending for __all__ repositories is returned. This method
  ///   always returns a result.
  ///
  /// - Parameters:
  ///   - language: Name of the lanauge to return.
  ///   - period: Interval of the trending.
  /// - Returns: `Single<[Trending.Repository]>`
  public func repositories(of language: String = "all", in period: Period = .pastDay)
    -> Single<[Trending.Repository]> {
    let url = Trending.url(of: .repository, language: language, period: period)

    return RxAlamofire.string(.get, url)
      .asSingle()
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
      .map(Trending.Repository.list)
  }

  /// Request GitHub trending developers.
  ///
  /// - Note: The `language` can be `all` or `unknown`, if a invalid string is
  ///   given, trending for __all__ developers is returned. This method
  ///   always returns a result.
  ///
  /// - Parameters:
  ///   - language: Name of the lanauge to return.
  ///   - period: Interval of the trending.
  /// - Returns: `Single<[Trending.Developer]>`
  public func developers(of language: String = "all", in period: Period = .pastDay)
    -> Single<[Trending.Developer]> {
    let url = Trending.url(of: .developer, language: language, period: period)

    return RxAlamofire.string(.get, url)
      .asSingle()
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
      .map(Trending.Developer.list)
  }

}
