import Foundation

import RxAlamofire
import RxSwift

import Kanna

import JacKit

public struct Trending {

  public enum Period: String {
    case day = "daily"
    case week = "weekly"
    case month = "monthly"
  }

  public enum Category {
    case repository
    case developer
  }

  fileprivate static func url(of catetory: Category, language: String? = nil, period: Period = .day) -> URL {

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

  public static func repositories(of language: String? = nil, in period: Period = .day)
    -> Single<[Trending.Repository]?> {
    let url = self.url(of: .repository, language: language, period: period)

    return RxAlamofire.string(.get, url)
      .asSingle()
      .map(Trending.Repository.list)
  }

  public static func developers(of language: String? = nil, in period: Period = .day)
    -> Single<[Trending.Developer]?> {
    let url = self.url(of: .developer, language: language, period: period)

    return RxAlamofire.string(.get, url)
      .asSingle()
      .map(Trending.Developer.list)
  }

}
