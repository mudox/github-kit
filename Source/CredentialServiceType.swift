import JacKit

private let jack = Jack("CredentialServiceType")

public protocol CredentialServiceType: AnyObject {
  var token: String? { get set }
  var user: (name: String, password: String)? { get set }
  var app: (key: String, secret: String)? { get set }

  var isAuthorized: Bool { get }
}

public extension CredentialServiceType {

  var isAuthorized: Bool {
    if token != nil {
      if user == nil {
        jack.descendant("isLoggedIn").warn("""
        inconsistence: `self.user` should not be nil when `self.token` is not nil
        """)
      }
      return true
    } else {
      return false
    }
  }

}
