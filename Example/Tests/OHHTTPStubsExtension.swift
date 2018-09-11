import Foundation

import OHHTTPStubs

fileprivate func parse(messageText text: String)
  -> (code: Int, header: [String: String], body: Data)
{
  let pattern = """
  ^
  HTTP/1.1 \\s+ (\\d+) \\s+ (\\w+)\\n            # Response line
  (.*)  \\n                                      # Header fileds
  \\n
  (.*)                                           # Bodyh
  $
  """

  let regex = try! NSRegularExpression(
    pattern: pattern,
    options: [
      .allowCommentsAndWhitespace,
      .dotMatchesLineSeparators,
    ]
  )

  let msgMatch = regex.firstMatch(in: text, options: [], range: NSMakeRange(0, text.count))!

  // Status code
  let codeText = (text as NSString).substring(with: msgMatch.range(at: 1))
  let code = Int(codeText)!

  // Header
  let headerString = (text as NSString).substring(with: msgMatch.range(at: 3))
  let headerList: [(String, String)] = headerString
    .split(separator: "\n")
    .map {
      let splitted = $0.split(separator: ":", maxSplits: 1).map(String.init)
      let key = splitted[0]
      let value = splitted[1].trimmingCharacters(in: .whitespaces)
      return (key, value)
    }
  let header = [String: String](uniqueKeysWithValues: headerList)

  let bodyString = (text as NSString).substring(with: msgMatch.range(at: 4))
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
