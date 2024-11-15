import Foundation

public struct SystemStatus: Decodable, Sendable {
  public let message: String
  public let status: Status?

  enum CodingKeys: CodingKey {
    case message, status
  }

  public init (message: String, status: Status? = nil) {
    self.message = message
    self.status = status
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.message = try container.decode(String.self, forKey: .message)
    self.status = try? container.decodeIfPresent(Status.self, forKey: .status)
  }
}

public enum Status: String, Decodable, Sendable {
  case normal
}
