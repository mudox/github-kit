import Foundation
import Moya

import RxSwift

// MARK: - Parse Link Header Field

private func _url(from text: String, using pattern: NSRegularExpression) -> URL? {
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

private func _pageIndex(from url: URL) -> Int? {
  guard
    let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
    let queryItems = components.queryItems,
    let pageItem = queryItems.first(where: { $0.name == "page" })
  else { return nil }

  return Int(pageItem.value ?? "")
}

// MARK: Patterns

private let _firstRegex = try? NSRegularExpression(pattern: "<([^>]+)>; rel=\"first\"")
private let _lastRegex = try? NSRegularExpression(pattern: "<([^>]+)>; rel=\"last\"")
private let _prevRegex = try? NSRegularExpression(pattern: "<([^>]+)>; rel=\"prev\"")
private let _nextRegex = try? NSRegularExpression(pattern: "<([^>]+)>; rel=\"next\"")

public enum Pagination {

  public enum Error: Swift.Error {
    case regexInitialization
    case invalidFieldContent
  }

  // MARK: - Cases

  /// If the list is not small enough to fit within a single page, GitHub
  /// endpoints would not inlude a **Link** header field in the response.
  case single
  /// The first page
  case first(next: URL, last: URL)
  /// The page in between
  case other(first: URL, last: URL, previous: URL, next: URL)
  /// The last page
  case last(previous: URL, first: URL)

  /// Initialize an instance of HTTP message header dictionary
  ///
  /// - Parameter headers: The HTTP message header dictionary.
  ///
  /// - Throws: `Pagination.Error`
  public init(from headers: [String: String]) throws {
    guard let text = headers["Link"] else {
      self = .single
      return
    }

    guard
      let firstRegex = _firstRegex,
      let lastRegex = _lastRegex,
      let nextRegex = _nextRegex,
      let prevRegex = _prevRegex
    else {
      throw Error.regexInitialization
    }

    let first = _url(from: text, using: firstRegex)
    let last = _url(from: text, using: lastRegex)
    let next = _url(from: text, using: nextRegex)
    let prev = _url(from: text, using: prevRegex)

    switch (first, last, prev, next) {

    case let (nil, last?, nil, next?):
      self = Pagination.first(next: next, last: last)

    case let (first?, last?, prev?, next?):
      self = Pagination.other(first: first, last: last, previous: prev, next: next)

    case let (first?, nil, prev?, nil):
      self = Pagination.last(previous: prev, first: first)

    default:
      throw Error.invalidFieldContent
    }
  }

  // MARK: - Computed Properties

  public var pageIndex: Int? {
    switch self {
    case .single, .first:
      return 0
    case let .other(_, _, _, nextURL):
      let nextIndex = _pageIndex(from: nextURL)
      return nextIndex?.advanced(by: -1)
    case let .last(prevURL, _):
      let prevIndex = _pageIndex(from: prevURL)
      return prevIndex?.advanced(by: 1)
    }
  }

  public var totalCount: Int? {
    switch self {
    case .single:
      return 1
    case let .first(_, lastURL):
      return _pageIndex(from: lastURL)
    case let .other(_, lastURL, _, _):
      return _pageIndex(from: lastURL)
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
        "total count": totalCount as Any,
      ]
    )
  }

}
