import Foundation
import Dependencies
import Model
import DependenciesMacros

// https://docs.wazirx.com/#public-rest-api-for-wazirx
// https://api.wazirx.com/sapi/v1/tickers/24hr

public enum HTTPMethod: String {
  case get = "GET"
}

public protocol APIEndpoint: Sendable {
  associatedtype Response: Decodable
  var httpMethod: HTTPMethod { get }
  var path: String { get }
  var queryItems: [URLQueryItem]? { get }
  var httpBody: Data? { get }
}

@DependencyClient
public struct ApiClient: Sendable {
  public var apiRequest: @Sendable (any APIEndpoint) async throws -> (data: Data, response: URLResponse)
  public var status: @Sendable (WazirxStatusEndpoint) async throws -> SystemStatus
  public var currency: @Sendable (WazirxCurrencyEndpoint) async throws -> CryptoCurrency
}

extension DependencyValues {
  public var apiClient: ApiClient {
    get { self[ApiClient.self] }
    set { self[ApiClient.self] = newValue }
  }
}

extension ApiClient: TestDependencyKey {
  public static var testValue: ApiClient {
    .init(
      apiRequest: { _ in (Data(), .init()) },
      status: { _ in .init(message: "System is running in Test Mode", status: .normal) },
      currency: { _ in
        let btc = CryptoCurrency(
          symbol: "btcinr",
          baseAsset: "btc",
          quoteAsset: "inr",
          openPrice: 5656600.0,
          lowPrice: 5656600.0,
          highPrice: 5656600.0,
          lastPrice: 5656600.0,
          volume: 0.0,
          bidPrice: 0.0,
          askPrice: 0.0,
          at: Date(timeIntervalSince1970: 1727329628)
        )
        return btc
      }
    )
  }
}
