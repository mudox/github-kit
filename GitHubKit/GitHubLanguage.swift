import Foundation

import RxAlamofire
import RxSwift

import Yams

import JacKit

public struct GitHubLanguage: Decodable {

  let name: String
  let color: String?

}

extension GitHubLanguage {

//  private static let cacheDirectory: URL = {
//    let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
//    return url.appendingPathComponent("GitHubKit/GitHubLanguages")
//  }()
//
//  private static let cacheFile: URL = {
//    cacheDirectory.appendingPathComponent("languages.yml")
//  }()

  public static var all: Single<[GitHubLanguage]> {
    let url = URL(string: "https://github.com/github/linguist/raw/master/lib/linguist/languages.yml")!
    return RxAlamofire.string(.get, url)
      .asSingle()
      .map { string -> [GitHubLanguage] in
        let decoder = YAMLDecoder()
        return try decoder.decode([String: _YAML].self, from: string).map { key, value in
          GitHubLanguage(name: key, color: value.color)
        }
      }
  }

  fileprivate struct _YAML: Decodable {
    let color: String?
  }

}
