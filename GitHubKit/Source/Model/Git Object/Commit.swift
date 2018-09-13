import Foundation

public struct Commit: Decodable {

  let sha: String

  let author: Participant
  let committer: Participant

  let tree: Commit.Tree

  let message: String

}

public extension Commit {

  struct Participant: Decodable {
    let name: String
    let email: String
    let date: Date

    // swiftlint:disable:next nesting
    private enum CodingKeys: String, CodingKey {
      case name
      case email
      case date
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      name = try container.decode(String.self, forKey: .name)
      email = try container.decode(String.self, forKey: .email)

      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      formatter.locale = Locale(identifier: "en_US_POSIX")

      let dateString = try container.decode(String.self, forKey: .date)
      guard let date = formatter.date(from: dateString) else {
        throw DecodingError.dataCorruptedError(
          forKey: .date, in: container,
          debugDescription: "parsing `.date` as RFC3339 date failed"
        )
      }
      self.date = date
    }

  }

  struct Tree: Decodable {
    let sha: String
  }

  struct Verification: Decodable {
    let isVerified: Bool
    let reason: String
    let signature: String
  }

}
