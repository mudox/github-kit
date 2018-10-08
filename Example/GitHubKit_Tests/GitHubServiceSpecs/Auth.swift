import Foundation

struct Auth {

  static var accessToken: String? {
    get { return UserDefaults.standard.string(forKey: "accessToken") }
    set { UserDefaults.standard.set(newValue, forKey: "accessToken") }
  }

  enum User {
    static let name = "cement_ce@163.com"
    static let password = "zheshi1geceshihao"
  }

  enum App {
    static let key = "c2dc8eb1cd09ac1e2381"
    static let secret = "1e6558ef27cd7844047b9de69dc009d0bd05579b"
  }
  
}
