import UIKit

import RxAlamofire
import RxSwift

import SwiftHEXColors
import Yams

import JacKit

private let jack = Jack("GitHub.Language").set(format: .short)

public struct Language {

  let name: String
  let color: UIColor?

}

extension Language {

  private static let url = URL(
    string: "https://github.com/github/linguist/raw/master/lib/linguist/languages.yml"
  )!

  public static var all: Single<[Language]> {
    return RxAlamofire.string(.get, url)
      .asSingle()
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
      .map { string -> [Language] in
        let decoder = YAMLDecoder()
        return try decoder.decode([String: YAMLDecoded].self, from: string)
          .map { key, value in
            let color = value.color.flatMap { colorString -> UIColor? in
              if let color = UIColor(hexString: colorString) {
                return color
              } else {
                jack.function().error("Unrecognized color string: \(colorString)")
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
