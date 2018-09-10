import Foundation

extension Payload {

  // MARK: - Payload.Search

  public struct Search: Decodable {

    public let totalCount: Int
    public let isInComplete: Bool
    public let items: [Repository]

    private enum CodingKeys: String, CodingKey {
      case totalCount = "total_count"
      case isInComplete = "incomplete_results"
      case items
    }

  }

  // MARK: - Payload.RateLimit

  public struct RateLimit: Decodable {

    public struct Limit: Decodable {
      public let limit: Int
      public let remaining: Int
      public let resetDate: Date

      private enum CodingKeys: String, CodingKey {
        case limit
        case remaining
        case resetDate = "reset"
      }

      public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        limit = try container.decode(Int.self, forKey: .limit)
        remaining = try container.decode(Int.self, forKey: .remaining)

        // Interpret date number as UTC epoch seconds (since 1970)
        let epochSeconds = try container.decode(TimeInterval.self, forKey: .resetDate)
        resetDate = Date(timeIntervalSince1970: epochSeconds)
      }
    }

    public struct Resources: Decodable {
      public let core: Limit
      public let search: Limit
      public let graphQL: Limit

      private enum CodingKeys: String, CodingKey {
        case core
        case search
        case graphQL = "graphql"
      }

    }

    public let rate: Limit
    public let resources: Resources
  }

}
