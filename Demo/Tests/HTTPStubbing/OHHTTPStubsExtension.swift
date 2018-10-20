import Foundation

import OHHTTPStubs

/// Parses the input HTTP message text, extracts out 3 components:
///
///   1. Status code (`String`)
///   2. Header fields (`[String: String]`)
///   3. Body (`Data`), return an empty `Data` instance when no
///      body has been found.
///
/// - Important: If the recorded response has no body (Content-Length: 0), do
///   NOT omiss the double new line which marks the end of header part.
///
/// - Parameter text: Input HTTP message text.
/// - Returns: The extracted 3 components if parsing succeeded.
private func parse(messageText text: String)
  -> (code: Int, header: [String: String], body: Data) {

  /*
   *
   * Step 0 - Unify EOLs to '\n'
   *
   */

  let mutableText = NSMutableString(string: text)

  let eolRegex = try! NSRegularExpression(
    pattern: "(?:\\n|\\r\\n|\\r)"
  )

  eolRegex.replaceMatches(in: mutableText, range: NSRange(location: 0, length: mutableText.length), withTemplate: "\n")

  let newText = mutableText as String

  /*
   *
   * Step 1 - Extract the 3 parts by regex
   *
   */

  let pattern = """
  ^
  HTTP/1.1 \\s+ (\\d+) \\s+ [^\\n]*  # Status Line
  \\n
  (.*?)                               # Header
  \\n\\n
  (.*)?                              # Body (optional)
  $
  """

  let msgRegex = try! NSRegularExpression(
    pattern: pattern,
    options: [
      .allowCommentsAndWhitespace,
      .dotMatchesLineSeparators
    ]
  )

  let msgMatch = msgRegex.firstMatch(
    in: newText,
    options: [],
    range: NSRange(location: 0, length: (newText as NSString).length)
  )!

  /*
   *
   * Step 2 - Status code
   *
   */

  let codeText = (newText as NSString).substring(with: msgMatch.range(at: 1))
  let code = Int(codeText)!

  /*
   *
   * Step 3 - Header dictionary
   *
   */

  let headerString = (newText as NSString).substring(with: msgMatch.range(at: 2))
  let headerList: [(String, String)] = headerString
    .split(separator: "\n")
    .map {
      let splitted = $0
        .split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
        .map(String.init)
      let key = splitted[0]
      let value = splitted[1].trimmingCharacters(in: .whitespaces)
      return (key, value)
    }
  let header = [String: String](headerList) { "\($0), \($1)" }

  /*
   *
   * Step 4 - Body data
   *
   */

  let body: Data
  if msgMatch.numberOfRanges > 2 {
    let bodyString = (newText as NSString).substring(with: msgMatch.range(at: 3))
    body = bodyString.data(using: .utf8)!
  } else {
    body = Data()
  }

  return (code, header, body)
}

extension OHHTTPStubsResponse {

  public convenience init(string: String) {
    let (code, header, body) = parse(messageText: string)
    self.init(data: body, statusCode: Int32(code), headers: header)
  }

  public convenience init(url: URL) {
    let text = try! String(contentsOf: url)
    self.init(string: text)
  }

  /// Extract status code, header dictionary and body data of a HTTP
  /// response text stored in the given file.
  ///
  /// - Parameters:
  ///   - filename: The recorded HTTP response text file.
  ///   - bundle: Bundle from which the file resides, default to current bundle.
  public convenience init(filename: String, bundle: Bundle = Bundle(for: ThisBundle.self)) {
    let url = bundle.url(
      forResource: (filename as NSString).deletingPathExtension,
      withExtension: (filename as NSString).pathExtension
    )!
    self.init(url: url)
  }

}

public class ThisBundle {}
