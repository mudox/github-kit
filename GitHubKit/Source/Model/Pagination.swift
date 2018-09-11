import Foundation
import Moya

import RxSwift

public enum Pagination {

  // MARK: - Parsing

  private static let firstRegex = try? NSRegularExpression(pattern: "<([^>]+)>; rel=\"first\"")
  private static let lastRegex = try? NSRegularExpression(pattern: "<([^>]+)>; rel=\"last\"")
  private static let prevRegex = try? NSRegularExpression(pattern: "<([^>]+)>; rel=\"prev\"")
  private static let nextRegex = try? NSRegularExpression(pattern: "<([^>]+)>; rel=\"next\"")

  private static func url(from text: String, using pattern: NSRegularExpression) -> URL? {
    guard
      let match = pattern.firstMatch(in: text, range: NSRange(location: 0, length: text.count))
    else {
      return nil
    }

    let range = match.range(at: 1)
    guard range.location != NSNotFound else {
      return nil
    }

    let urlString = (text as NSString).substring(with: range)
    return URL(string: urlString)
  }

  private static func pageIndex(from url: URL) -> Int? {
    guard
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
      let queryItems = components.queryItems,
      let pageItem = queryItems.first(where: { $0.name == "page" })
    else { return nil }

    return Int(pageItem.value ?? "")
  }

  // MARK: - Cases

  case first(next: URL, last: URL)
  case other(first: URL, last: URL, previous: URL, next: URL)
  case last(previous: URL, first: URL)

  public init?(from headers: [String: String]) {
    guard let text = headers["Link"] else { return nil }

    guard
      let firstRegex = Pagination.firstRegex,
      let lastRegex = Pagination.lastRegex,
      let nextRegex = Pagination.nextRegex,
      let prevRegex = Pagination.prevRegex
    else {
      return nil
    }

    let first = Pagination.url(from: text, using: firstRegex)
    let last = Pagination.url(from: text, using: lastRegex)
    let next = Pagination.url(from: text, using: nextRegex)
    let prev = Pagination.url(from: text, using: prevRegex)

    switch (first, last, prev, next) {

    case let (nil, last?, nil, next?):
      self = Pagination.first(next: next, last: last)

    case let (first?, last?, prev?, next?):
      self = Pagination.other(first: first, last: last, previous: prev, next: next)

    case let (first?, nil, prev?, nil):
      self = Pagination.last(previous: prev, first: first)

    default:
      print("unexpected combination")
      return nil
    }
  }

  // MARK: - Computed Properties

  public var pageIndex: Int? {
    switch self {
    case .first:
      return 0
    case let .other(_, _, _, nextURL):
      let nextIndex = Pagination.pageIndex(from: nextURL)
      return nextIndex?.advanced(by: -1)
    case let .last(prevURL, _):
      let prevIndex = Pagination.pageIndex(from: prevURL)
      return prevIndex?.advanced(by: 1)
    }
  }

  public var totalCount: Int? {
    switch self {
    case let .first(_, lastURL):
      return Pagination.pageIndex(from: lastURL)
    case let .other(_, lastURL, _, _):
      return Pagination.pageIndex(from: lastURL)
    case .last:
      return pageIndex
    }
  }
}

// MARK: - CustomReflectable

extension Pagination: CustomReflectable {

  public var customMirror: Mirror {
    return Mirror(
      Pagination.self,
      children: [
        "page index": pageIndex as Any,
        "total count": totalCount as Any
      ]
    )
  }

}
