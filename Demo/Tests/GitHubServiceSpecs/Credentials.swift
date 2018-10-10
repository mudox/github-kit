import Foundation

import GitHub

import JacKit

class Credentials: CredentialServiceType {
  
  // MARK: - Singleton
  
  static let shared = Credentials()
  
  private init() {}
  
  // MARK: - CredentialServiceType

  var token: String? {
    get {
      if let token = UserDefaults.standard.string(forKey: "accessToken") {
        return token
      } else {
        Jack("Vault").warn("no access token")
        return nil
      }
    }
    set {
      UserDefaults.standard.set(newValue, forKey: "accessToken")

    }
  }

  var user: (name: String, password: String)? = (
    name: "cement_ce@163.com",
    password: "zheshi1geceshihao"
  )

  var app: (key: String, secret: String)? = (
    key: "c2dc8eb1cd09ac1e2381",
    secret: "1e6558ef27cd7844047b9de69dc009d0bd05579b"
  )

}
