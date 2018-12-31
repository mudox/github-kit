import Foundation

struct NSCodingCodable<Wrapped>: Codable where Wrapped: NSCoding {

  var wrapped: Wrapped

  init(_ wrapped: Wrapped) { self.wrapped = wrapped }

  private enum CodingKeys: String, CodingKey {
    case wrapped
  }

  init(from decoder: Decoder) throws {

    let container = try decoder.container(keyedBy: CodingKeys.self)
    let data = try container.decode(Data.self, forKey: .wrapped)

    guard let unarchived = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) else {
      throw DecodingError.dataCorruptedError(
        forKey: .wrapped,
        in: container,
        debugDescription: "Data can not be unarchived"
      )
    }

    guard let wrapped = unarchived as? Wrapped else {
      let context = DecodingError.Context(
        codingPath: container.codingPath,
        debugDescription: "Unarchived object type was \(type(of: unarchived))"
      )
      throw DecodingError.typeMismatch(Wrapped.self, context)
    }

    self.wrapped = wrapped

  }

  func encode(to encoder: Encoder) throws {

    let data: Data
    if #available(iOS 12, *) {
      data = try NSKeyedArchiver.archivedData(withRootObject: wrapped, requiringSecureCoding: true)
    } else {
      data = NSKeyedArchiver.archivedData(withRootObject: wrapped)
    }

    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(data, forKey: .wrapped)
  }

}
