import Foundation

import RxAlamofire
import RxSwift

import Yams

import JacKit

public struct GitHubLanguage: Decodable {

  let name: String
  let color: String

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

  internal static var all: Single<[GitHubLanguage]> {
    let url = URL(string: "https://github.com/github/linguist/raw/master/lib/linguist/languages.yml")!
    return RxAlamofire.string(.get, url)
      .asSingle()
      .map { string -> [GitHubLanguage] in
        let decoder = YAMLDecoder()
        return try decoder.decode([GitHubLanguage].self, from: string)
      }
  }

}
