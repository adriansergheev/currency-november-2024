import Foundation
import Model

public enum ExchangeEndPoint {
  case fetch
}

extension ExchangeEndPoint: APIEndpoint {
  public typealias Response = Exchange

  public var httpMethod: HTTPMethod {
    .get
  }

  public var path: String {
    "/latest"
  }

  public var queryItems: [URLQueryItem]? {
    [.init(name: "base", value: "USD")]
  }

  public var httpBody: Data? {
    nil
  }
}
