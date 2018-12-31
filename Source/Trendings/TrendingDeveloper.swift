import Foundation

import Kanna

import JacKit

private let jack = Jack().set(format: .short).set(level: .warning)

public extension Trending {

  struct Developer: Codable {
    public let avatarURL: URL
    public let name: String
    public let displayName: String?
    public let repositoryName: String
    public let repositoryDescription: String
  }

}
