import Foundation

import RxAlamofire
import RxSwift

import Kanna

import JacKit

public struct GitHubTrending {

  public enum Period: String {
    case pastDay = "daily"
    case pastWeek = "weekly"
    case pastMonth = "monthly"
  }

  public enum Category {
    case trendingRepositories
    case trendingDevelopers
  }

  fileprivate static func url(of catetory: Category, language: String? = nil, period: Period = .pastDay) -> URL {

    var urlComponents: URLComponents
    switch catetory {
    case .trendingRepositories:
      urlComponents = URLComponents(string: "https://github.com/trending")!
    case .trendingDevelopers:
      urlComponents = URLComponents(string: "https://github.com/trending/developers")!
    }

    if let language = language {
      urlComponents.path.append("/\(language)")
    }

    urlComponents.queryItems = [URLQueryItem(name: "since", value: period.rawValue)]

    return urlComponents.url!
  }

  public static func repositories(of language: String? = nil, in period: Period = .pastDay)
    -> Single<[GitHubTrending.Repository]?> {
    let url = self.url(of: .trendingRepositories, language: language, period: period)

    return RxAlamofire.string(.get, url)
      .asSingle()
      .map(GitHubTrending.Repository.list)
  }

  public static func developers(of language: String? = nil, in period: Period = .pastDay)
    -> Single<[GitHubTrending.Developer]?> {
    let url = self.url(of: .trendingDevelopers, language: language, period: period)

    return RxAlamofire.string(.get, url)
      .asSingle()
      .map(GitHubTrending.Developer.list)
  }

}
