import Foundation

import JacKit

struct Vault {

  static var token: String? {
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

  static let user = (
    name: "cement_ce@163.com",
    password: "zheshi1geceshihao"
  )

  static let app = (
    key: "c2dc8eb1cd09ac1e2381",
    secret: "1e6558ef27cd7844047b9de69dc009d0bd05579b"
  )

}
