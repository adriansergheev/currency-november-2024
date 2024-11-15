import Foundation
import Model

public enum WazirxStatusEndpoint {
  case fetch
}

extension WazirxStatusEndpoint: APIEndpoint {
  public typealias Response = SystemStatus

  public var httpMethod: HTTPMethod {
    .get
  }

  public var path: String {
    "/sapi/v1/systemStatus"
  }

  public var queryItems: [URLQueryItem]? {
    nil
  }

  public var httpBody: Data? {
    nil
  }
}
