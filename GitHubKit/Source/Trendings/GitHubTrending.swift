import Foundation

import RxAlamofire
import RxSwift

import Kanna

import JacKit

public struct GitHubTrending {

  public enum Period: String {
    case daily
    case weekly
    case monthly
  }

  public enum Category {
    case repository
    case deveoloper
  }

  fileprivate static let developerBaseURLString = "https://github.com/trending/developers"

  fileprivate static func htmlPageURL(
    of catetory: Category,
    language: String? = nil,
    period: Period = .daily
  )
    -> URL {

    var urlComponents: URLComponents
    switch catetory {
    case .repository:
      urlComponents = URLComponents(string: "https://github.com/trending")!
    case .deveoloper:
      urlComponents = URLComponents(string: "https://github.com/trending/developers")!
    }

    if let lan = language {
      urlComponents.path.append("/\(lan)")
    }

    urlComponents.queryItems = [URLQueryItem(name: "since", value: period.rawValue)]

    return urlComponents.url!
  }

  public static func trendings(
    of category: Category,
    language: String? = nil,
    period: Period = .daily
  )
    -> Single<[GitHubTrending.Repository]?> {
    let jack = Jack("GitHubTrending")

    let url = htmlPageURL(of: category, language: language, period: period)
    return string(.get, url)
      .asSingle()
      // Parse HTML string for `Trending` arrays
      .map(GitHubTrending.Repository.trendings)
  }

}
