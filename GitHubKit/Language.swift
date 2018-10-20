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

  public static var all: Single<[Language]> {
    let url = URL(string: "https://github.com/github/linguist/raw/master/lib/linguist/languages.yml")!
    return RxAlamofire.string(.get, url)
      .map { string -> [Language] in
        let decoder = YAMLDecoder()
        return try decoder.decode([String: YAML].self, from: string).map { key, value in
          Language(name: key, color: value.color)
        }
      }
      .asSingle()
  }

  fileprivate struct YAML: Decodable {
    let color: String?
  }

}
