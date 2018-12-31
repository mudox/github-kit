import Foundation

import Kanna
import SwiftHEXColors

import JacKit

private let jack = Jack().set(level: .warning)

public extension Trending {

  public struct Repository: Codable {
    public let title: String
    public let summary: String

    public let language: Language?

    public let starsCount: Int
    public let forksCount: Int?
    public let gainedStarsCount: Int?

    public let contributors: [Contributor]
  }

}

// MARK: - Computed Properties

public extension Trending.Repository {

  var owner: String {
    guard let owner = title.split(separator: "/").first else {
      jack.sub("owner.getter").error("can not extract repo owner from `.title`")
      return ""
    }
    return String(owner)
  }

  var name: String {
    guard let name = title.split(separator: "/").last else {
      jack.sub("name.getter").error("can not extract repo name from `.title`")
      return ""
    }
    return String(name)
  }

}

// MARK: - Nested Types

public extension Trending.Repository {

  struct Language: Codable {

    public let name: String

    private let _color: NSCodingCodable<UIColor>?
    public var color: UIColor? {
      return _color?.wrapped
    }

    init(name: String, color: UIColor?) {
      self.name = name
      if let color = color {
        _color = NSCodingCodable(color)
      } else {
        _color = nil
      }
    }

    // swiftlint:disable:next nesting
    private enum CodingKeys: String, CodingKey {
      case name
      case _color = "color"
    }
  }

  struct Contributor: Codable {
    let name: String
    let avatar: URL?
  }

}
