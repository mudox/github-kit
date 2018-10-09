import Foundation

import RxAlamofire
import RxSwift

import Yams

import JacKit

public struct Language: Decodable {

  let name: String
  let color: String?

}

extension Language {

//  private static let cacheDirectory: URL = {
//    let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
//    return url.appendingPathComponent("GitHubKit/GitHubLanguages")
//  }()
//
//  private static let cacheFile: URL = {
//    cacheDirectory.appendingPathComponent("languages.yml")
//  }()

  public static var all: Single<[Language]> {
    let url = URL(string: "https://github.com/github/linguist/raw/master/lib/linguist/languages.yml")!
    return RxAlamofire.string(.get, url)
      .asSingle()
      .map { string -> [Language] in
        let decoder = YAMLDecoder()
        return try decoder.decode([String: _YAML].self, from: string).map { key, value in
          Language(name: key, color: value.color)
        }
      }
  }

  fileprivate struct _YAML: Decodable {
    let color: String?
  }

}
