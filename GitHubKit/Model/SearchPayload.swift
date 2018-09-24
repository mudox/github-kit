import Foundation

public struct SearchPayload: Decodable {

  public let totalCount: Int
  public let isInComplete: Bool
  public let items: [Repository]

  private enum CodingKeys: String, CodingKey {
    case totalCount = "total_count"
    case isInComplete = "incomplete_results"
    case items
  }

}
