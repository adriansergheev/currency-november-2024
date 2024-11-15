import Foundation
import Model

public enum WazirxCurrencyEndpoint: Sendable {
  case fetch(Symbol)
}

public enum Symbol: String, Sendable {
  case btcusdt
  case ethusdt
  case ltcusdt

  case btcinr
  case ltcinr
  case dogeinr
}

extension WazirxCurrencyEndpoint: APIEndpoint {
  public typealias Response = CryptoCurrency

  public var httpMethod: HTTPMethod {
    .get
  }

  public var path: String {
    "/sapi/v1/ticker/24hr"
  }

  public var queryItems: [URLQueryItem]? {
    switch self {
    case let .fetch(currencySymbol):
      [.init(name: "symbol", value: currencySymbol.rawValue)]
    }
  }

  public var httpBody: Data? {
    nil
  }
}
