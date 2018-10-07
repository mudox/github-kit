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

  struct Headers {
    
    static let acceptJSON = ["Accept": "application/vnd.github.v3+json"]
    static let acceptTopics = ["Accept": "application/vnd.github.mercy-preview+jso"]

    // MARK: - Authorization Header Values

    private static func base64Encode(username: String, password: String) -> String {
      let text = "\(username):\(password)"
      let data = text.data(using: .utf8)!
      return data.base64EncodedString()
    }

    internal static func authorization(username: String, password: String) -> [String: String] {
      return ["Authorization": "Basic \(base64Encode(username: username, password: password))"]
    }

    internal static func authorization(appKey: String, appSecret: String) -> [String: String] {
      return ["Authorization": "Basic \(base64Encode(username: appKey, password: appSecret))"]
    }

    internal static func authorization(accessToken: String) -> String {
      return "Token \(accessToken)"
    }

  }

}
