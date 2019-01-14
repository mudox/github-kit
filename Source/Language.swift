import UIKit

import RxAlamofire
import RxSwift

import SwiftHEXColors
import Yams

import JacKit

private let jack = Jack("GitHub.Language").set(format: .short)

public struct Language: Codable {

  public let name: String

  private let colorString: String?

  public var color: UIColor? {
    guard let text = colorString else { return nil }
    guard let color = UIColor(hexString: text) else {
      jack.func().warn("Unrecognized color string: \(text), return nil")
      return nil
    }
    return color
  }

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
          .map { Language(name: $0, colorString: $1.color) }
      }
  }

  fileprivate struct YAMLDecoded: Decodable {
    let color: String?
  }

}
