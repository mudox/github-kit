import Foundation

import RxAlamofire
import RxSwift

import Kanna

import JacKit

private let jack = Jack().set(format: .short).set(level: .warning)

public struct Trending {

  public enum Error: Swift.Error {
    case htmlParsing
    case isDissecting
  }

  public enum Period: String {
    case today = "daily"
    case thisWeek = "weekly"
    case thisMonth = "monthly"
  }

  public enum Category {
    case repository
    case developer
  }

  // MARK: - Private

  fileprivate static func url(of catetory: Category, language: String, period: Period = .today) -> URL {

    var urlComponents: URLComponents

    switch catetory {
    case .repository:
      urlComponents = URLComponents(string: "https://github.com/trending")!
    case .developer:
      urlComponents = URLComponents(string: "https://github.com/trending/developers")!
    }

    urlComponents.path.append("/\(language.lowercased())")
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
  public func repositories(of language: String = "all", for period: Period = .today)
    -> Single<[Trending.Repository]> {
    let url = Trending.url(of: .repository, language: language, period: period)
    jack.function().debug("new request with url: \(url)")

    return RxAlamofire.string(.get, url)
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
      .map(Trending.Repository.list)
      .asSingle()
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
  public func developers(of language: String = "all", for period: Period = .today)
    -> Single<[Trending.Developer]> {
    let url = Trending.url(of: .developer, language: language, period: period)

    return RxAlamofire.string(.get, url)
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
      .map(Trending.Developer.list)
      .asSingle()
  }

}
