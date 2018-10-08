/// Factory class for creating common HTTP header fields required by the GitHub API v3.
internal struct Headers {

  // MARK: - Accept

  internal enum Accept {
    static let `default` = ["Accept": "application/vnd.github.v3+json"]
    static let topics = ["Accept": "application/vnd.github.mercy-preview+json"]
    static let textMatch = ["Accept": "application/vnd.github.v3.text-match+json"]
    static let raw = ["Accept": "application/vnd.github.v3.raw+json"]
  }

  // MARK: - Authorization

  internal enum Authorization {

    private static func base64Encode(username: String, password: String) -> String {
      let text = "\(username):\(password)"
      let data = text.data(using: .utf8)!
      return data.base64EncodedString()
    }

    internal static func user(name: String, password: String) -> String {
      return "Basic \(base64Encode(username: name, password: password))"
    }

    internal static func app(key: String, secret: String) -> String {
      return "Basic \(base64Encode(username: key, password: secret))"
    }

    internal static func accessToken(_ token: String) -> String {
      return "Token \(token)"
    }
  }

}
