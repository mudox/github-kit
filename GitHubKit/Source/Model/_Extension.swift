import Foundation

protocol JSONDecodable: Decodable {
  static func decode(jsonData: Data) throws -> Self
  static func decode(jsonString: String) throws -> Self
}

protocol JSONEncodable: Encodable {
  var jsonData: Data? { get }
  var jsonString: String? { get }
}

extension JSONDecodable {
  /// Returns an instance by decoding the data argument
  ///
  /// - Parameter string: string
  /// - Returns: The decoded instance
  /// - Throws: Swift.DecodingError
  static func decode(jsonData data: Data) throws -> Self {
    return try JSONDecoder().decode(Self.self, from: data)
  }

  /// Returns an instance by decoding the JSON string, using .utf8
  /// to encode String argumetn into Data
  ///
  /// - Parameter string: string
  /// - Returns: The decoded instance
  /// - Throws: `Swift.DecodingError`
  static func decode(jsonString: String) throws -> Self {
    let data = jsonString.data(using: .utf8)!
    return try JSONDecoder().decode(Self.self, from: data)
  }
}

extension JSONEncodable {
  func jsonData() throws -> Data {
    return try JSONEncoder().encode(self)
  }

  func jsonString() throws -> String {
    let data = try jsonData()
    return String(data: data, encoding: .utf8)!
  }
}
