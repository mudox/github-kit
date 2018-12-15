import UIKit

import RxAlamofire
import RxSwift

import SwiftHEXColors
import Yams

import JacKit

private let jack = Jack().set(format: .short)

public struct Language {

  let name: String
  let color: UIColor?

}

extension Language {

  private static let downloadURL = URL(
    string: "https://github.com/github/linguist/raw/master/lib/linguist/languages.yml"
  )!

  /// Application Support/GitHubKit/GitHub.Language
  private static let cacheURL: URL = {
    let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    return url.appendingPathComponent("GitHubKit/languages.yml")
  }()

  private static var allLanguagesString: Single<String> {
    return Single.just(cacheURL)
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
      .map { url -> String in
        let string = try String(contentsOf: url, encoding: .utf8)
        jack.function().debug("got languages from cache")
        return string
      }
      .catchError { error in
        jack.warn("""
        Failed to read languages from cache with error: \(error)
        Fallback to requesting from network.
        """)

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
        return try decoder.decode([String: YAMLDecoded].self, from: string)
          .map { key, value in
            let color = value.color.flatMap { colorString -> UIColor? in
              if let color = UIColor(hexString: colorString) {
                return color
              } else {
                jack.function().error("unrecognizable color string: \(colorString)")
                return nil
              }
            }
            return Language(name: key, color: color)
          }
      }
  }

  fileprivate struct YAMLDecoded: Decodable {
    let color: String?
  }

}
