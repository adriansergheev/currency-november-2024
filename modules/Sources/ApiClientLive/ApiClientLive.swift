import Foundation
import ApiClient
import Dependencies

extension ApiClient: DependencyKey {
  public static var liveValue: ApiClient {
    Self(
      apiRequest: { apiEndpoint in try await Self.apiRequest(apiEndpoint: apiEndpoint)},
      status: { endpoint in
        guard let request = Self.makeRequest(for: endpoint)
        else { throw URLError(.badURL) }
        let (data, _) = try await apiRequest(request)
        return try apiDecode(data: data, as: WazirxStatusEndpoint.Response.self)
      },
      currency: { endpoint in
        guard let request = Self.makeRequest(for: endpoint)
        else { throw URLError(.badURL) }
        let (data, _) = try await apiRequest(request)
        return try apiDecode(data: data, as: WazirxCurrencyEndpoint.Response.self)
      },
      exchange: { endpoint in
        guard let request = Self.makeRequest(for: endpoint, host: "api.frankfurter.app")
        else { throw URLError(.badURL) }
        let (data, _) = try await apiRequest(request)
        return try apiDecode(data: data, as: ExchangeEndPoint.Response.self)
      }
    )
  }
}

public let jsonDecoder = JSONDecoder()
public let jsonEncoder = JSONEncoder()

extension ApiClient {
  static func apiRequest(
    apiEndpoint: any APIEndpoint
  ) async throws -> (data: Data, response: URLResponse) {
    guard let request = makeRequest(for: apiEndpoint) else {
      throw URLError(.badURL)
    }
    return try await apiRequest(request)
  }

  static func apiRequest(
    _ request: URLRequest
  ) async throws -> (data: Data, response: URLResponse) {
    let (data, response) = try await URLSession.shared.data(for: request)
#if DEBUG
    print(
 """
 Request: \(request.url?.absoluteString ?? "")
 Status: \((response as? HTTPURLResponse)?.statusCode ?? 0)
 Response: \(String(decoding: data, as: UTF8.self))
 """
    )
#endif
    return (data, response)
  }

  static func makeRequest(
    for apiEndpoint: any APIEndpoint,
    host: String? = "api.wazirx.com"
  ) -> URLRequest? {
    guard let request = request(for: apiEndpoint, host: host) else { return nil }
    //    addHeaders(to: &request)
    return request
  }

  private static func request(
    for apiEndpoint: any APIEndpoint,
    host: String?
  ) -> URLRequest? {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = host
    urlComponents.path = apiEndpoint.path
    urlComponents.queryItems = apiEndpoint.queryItems

    guard let url = urlComponents.url else {
#if DEBUG
      print(
 """
 URL Components is malformed. Check \(String(describing: urlComponents.scheme)), \(urlComponents.path)
 """
      )
#endif
      return nil
    }
    var request = URLRequest(url: url)
    request.httpMethod = apiEndpoint.httpMethod.rawValue
    request.httpBody = apiEndpoint.httpBody
    return request
  }

  // TODO: - add headers if needed
  //  private static func addHeaders(to request: inout URLRequest) {
  //  }

  func apiRequest<T: Decodable>(
    _ apiEndpoint: any APIEndpoint,
    as: T.Type
  ) async throws -> T {
    do {
      let data = try await apiRequest(apiEndpoint).data
      return try Self.apiDecode(data: data, as: T.self)
    }
  }

  static func apiDecode<T: Decodable>(data: Data, as: T.Type) throws -> T {
    do {
      return try jsonDecoder.decode(T.self, from: data)
    }
  }
}
