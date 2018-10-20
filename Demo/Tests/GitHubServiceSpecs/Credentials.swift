import Foundation

import GitHub

import JacKit

class Credentials: CredentialServiceType {

  static let validUser = (
    name: "cement_ce@163.com",
    password: "zheshi1geceshihao"
  )
  
  static let validApp = (
    key: "c2dc8eb1cd09ac1e2381",
    secret: "1e6558ef27cd7844047b9de69dc009d0bd05579b"
  )

  static let invalidUser = (
    name: "ce_cement@163.com",
    password: "zheshi1geceshihao123"
  )
  
  static let invalidApp = (
    key: "c2dc8eb1cd09ac1e2081",
    secret: "1e6558ef27cd7804047b9de69dc009d0bd05579b"
  )

  static let valid = Credentials(
    user: validUser,
    app: validApp
  )

  init(
    user: (name: String, password: String),
    app: (key: String, secret: String)
  ) {
    self.user = user
    self.app = app
  }

  // MARK: - CredentialServiceType

  var token: String? {
    get {
      if let token = UserDefaults.standard.string(forKey: "accessToken") {
        return token
      } else {
        Jack("Credentials").warn("no access token")
        return nil
      }
    }
    set {
      UserDefaults.standard.set(newValue, forKey: "accessToken")

    }
  }

  var user: (name: String, password: String)?

  var app: (key: String, secret: String)?
}
