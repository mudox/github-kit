import Foundation

import RxAlamofire
import RxSwift

import Kanna

import JacKit

public struct Trending {

  public enum Period: String {
    case pastDay = "daily"
    case pastWeek = "weekly"
    case pastMonth = "monthly"
  }

  public enum Category {
    case repository
    case developer
  }

  fileprivate static func url(of catetory: Category, language: String? = nil, period: Period = .pastDay) -> URL {

    var urlComponents: URLComponents
    switch catetory {
    case .repository:
      urlComponents = URLComponents(string: "https://github.com/trending")!
    case .developer:
      urlComponents = URLComponents(string: "https://github.com/trending/developers")!
    }

    if let language = language {
      urlComponents.path.append("/\(language)")
    }

    urlComponents.queryItems = [URLQueryItem(name: "since", value: period.rawValue)]

    return urlComponents.url!
  }

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
  public static func repositories(of language: String? = nil, in period: Period = .pastDay)
    -> Single<[Trending.Repository]?> {
    let url = self.url(of: .repository, language: language, period: period)

    return RxAlamofire.string(.get, url)
      .asSingle()
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
  public static func developers(of language: String? = nil, in period: Period = .pastDay)
    -> Single<[Trending.Developer]?> {
    let url = self.url(of: .developer, language: language, period: period)

    return RxAlamofire.string(.get, url)
      .asSingle()
      .map(Trending.Developer.list)
  }

}
