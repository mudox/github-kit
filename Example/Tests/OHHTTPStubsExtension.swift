import Foundation

import OHHTTPStubs

fileprivate func parse(messageText text: String)
  -> (code: Int, header: [String: String], body: Data)
{

  /*
   *
   * Step 0 - Unify EOL to '\n'
   *
   */

  let mutableText = NSMutableString(string: text)

  let eolRegex = try! NSRegularExpression(
    pattern: "(?:\\n|\\r\\n|\\r)"
  )

  eolRegex.replaceMatches(in: mutableText, range: NSMakeRange(0, mutableText.length), withTemplate: "\n")

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
  (.*)                               # Header
  \\n\\n
  (.*)                               # Body
  $
  """

  let msgRegex = try! NSRegularExpression(
    pattern: pattern,
    options: [
      .allowCommentsAndWhitespace,
      .dotMatchesLineSeparators,
    ]
  )

  let msgMatch = msgRegex.firstMatch(
    in: newText,
    options: [],
    range: NSMakeRange(0, (newText as NSString).length)
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
  let header = [String: String](headerList, uniquingKeysWith: +)

  /*
   *
   * Step 4 - Body data
   *
   */

  let bodyString = (newText as NSString).substring(with: msgMatch.range(at: 3))
  let body = bodyString.data(using: .utf8)!

  return (code, header, body)
}

extension OHHTTPStubsResponse {

  public convenience init(responseMessage text: String) {
    let (code, header, body) = parse(messageText: text)
    self.init(data: body, statusCode: Int32(code), headers: header)
  }

  public convenience init(responseFileURL url: URL) {
    let data = FileManager.default.contents(atPath: url.absoluteString)!
    let text = String(data: data, encoding: .utf8)!
    self.init(responseMessage: text)
  }

  public convenience init(responseFileName filename: String, inBundleForClass type: AnyClass) {
    let path = OHPathForFile(filename, type)!
    let url = URL(string: path)!
    self.init(responseFileURL: url)
  }
}
