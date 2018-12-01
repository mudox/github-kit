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

  private static let downloadURL = URL(string: "https://github.com/github/linguist/raw/master/lib/linguist/languages.yml")!

  /// Application Support/GitHubKit/GitHub.Language
  private static let cacheURL: URL = {
    let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    return url.appendingPathComponent("GitHubKit/languages.json")
  }()

  private static var allLanguagesString: Single<String> {
    if FileManager.default.fileExists(atPath: cacheURL.path) {
      return Single.just(cacheURL)
        .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
        .map { url -> String in
          return try String(contentsOf: url, encoding: .utf8)
        }
    } else {
      return RxAlamofire.string(.get, downloadURL)
        .do(onNext: { string in
          try string.write(to: cacheURL, atomically: true, encoding: .utf8)
        })
        .asSingle()
    }
  }
  
  public static var all: Single<[Language]> {
    return allLanguagesString
    .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    .map { string -> [Language] in
      let decoder = YAMLDecoder()
      return try decoder.decode([String: YAML].self, from: string)
        .map { key, value in
          Language(name: key, color: value.color)
        }
    }
  }

  fileprivate struct YAML: Decodable {
    let color: String?
  }

}
