import Foundation

import OHHTTPStubs

import JacKit

public struct NetworkStubbing {

  private init() {}

  /// Set `$HTTP_STUBBING` to 'YES' to enabled stubbing.
  public static var isEnabled: Bool = {
    let environValue = ProcessInfo.processInfo.environment["HTTP_STUBBING"] ?? "NO"
    let enabled = (environValue == "YES")
    let jack = Jack("NetworkStubbing")

    if enabled {
      jack.debug("""
      is enabled ($HTTP_STUBBING == YES)
      """, options: [.compact, .noLocation])
    } else {
      jack.debug("""
      is NOT enabled ($HTTP_STUBBING != YES)
      """, options: [.compact, .noLocation])
    }

    return enabled
  }()

  public static func setup() {
    
    guard isEnabled else { return }

    let jack = Jack("Test.OHHTTPStubs").set(options: .noLocation)

    OHHTTPStubs.onStubActivation { request, stub, _ in
      jack.descendant("onStubActivation").debug("""
      hit : \(request)
      by  : \(stub.name ?? "<anonymous stub>")
      """)
    }

    OHHTTPStubs.onStubMissing { request in
      jack.descendant("onStubMissing").warn("""
      miss hit test: \(request.httpMethod!) - \(request.url!)"
      """)
    }
  }

  @discardableResult
  public static func stubIfEnabled(
    name: String,
    condition: @escaping OHHTTPStubsTestBlock
  )
    -> OHHTTPStubsDescriptor? {
    if isEnabled {
      let s = stub(
        condition: condition,
        response: { _ in OHHTTPStubsResponse(filename: "\(name).txt") }
      )
      s.name = name
      return s
    } else {
      return nil
    }
  }
}
