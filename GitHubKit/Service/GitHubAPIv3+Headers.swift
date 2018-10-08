extension GitHubAPIv3 {
  // MARK: - Private

//
//  private static let username = "cempri@163.com"
//  private static let password = "ximeng1983gh"
//
//  static let clientID = "46cfca605f029f4fdb3e"
//  static let clientSecret = "fba5480ff4d87ce83daf3b452da1585ddb5f5857"
//
//  private static let accessToken = "b3554f2b24f522a441202563199ca3ccdc9df441"

  internal struct Headers {

    // MARK: - Accept

    // swiftlint:disable:next nesting
    internal enum Accept {
      static let `default` = ["Accept": "application/vnd.github.v3+json"]
      static let topics = ["Accept": "application/vnd.github.mercy-preview+json"]
      static let textMatch = ["Accept": "application/vnd.github.v3.text-match+json"]
      static let raw = ["Accept": "application/vnd.github.v3.raw+json"]
    }

    // MARK: - Authorization

    // swiftlint:disable:next nesting
    internal enum Authorization {

      private static func base64Encode(username: String, password: String) -> String {
        let text = "\(username):\(password)"
        let data = text.data(using: .utf8)!
        return data.base64EncodedString()
      }

      internal static func user(name: String, password: String) -> [String: String] {
        return ["Authorization": "Basic \(base64Encode(username: name, password: password))"]
      }

      internal static func app(key: String, secret: String) -> [String: String] {
        return ["Authorization": "Basic \(base64Encode(username: key, password: secret))"]
      }

      internal static func accessToken(_ token: String) -> String {
        return "Token \(token)"
      }
    }

  }

}
