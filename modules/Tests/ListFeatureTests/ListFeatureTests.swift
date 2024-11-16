import Testing
import Model
import Foundation
import Dependencies
import ApiClient
@testable import ListFeature

@MainActor
@Suite
struct ListFeatureTests {
  @Test
  func status() throws {
    let model = ListModel()
    model.openStatusButtonTapped()
    _ = try #require(model.destination?.status)

    model.dismissStatusButtonTapped()
    #expect(model.destination == nil)
  }

  func success() async throws {
    var api = ApiClient.testValue
    api.exchange = { _ in
      Issue.record("exchange should not be called")
      return .init(amount: 1, base: "", rates: [:])
    }
    let clock = TestClock()
    let model = withDependencies {
      $0.apiClient = api
      $0.continuousClock = clock
    } operation: {
      ListModel()
    }

    await model.task()
    await clock.advance(by: .seconds(1))
    #expect(model.error == nil)
    #expect(!model.cryptoCurrencies.isEmpty)
  }

  func successSEK() async throws {
    let api = ApiClient.testValue
    let clock = TestClock()
    let model = withDependencies {
      $0.apiClient = api
      $0.continuousClock = clock
    } operation: {
      ListModel()
    }

    model.currency = .sek
    await model.task()
    await clock.advance(by: .seconds(1))
    #expect(model.error == nil)
    #expect(!model.cryptoCurrencies.isEmpty)
    try #require(model.cryptoCurrencies.first?.quoteAsset == "USD")
  }

  func error() async throws {
    var api = ApiClient.testValue
    let clock = TestClock()
    api.currency = { _ in throw NSError() as Error }
    let model = withDependencies {
      $0.apiClient = api
      $0.continuousClock = clock
    } operation: {
      ListModel()
    }

    await model.task()
    #expect(model.error == nil)
    await clock.advance(by: .seconds(1))
    #expect(model.cryptoCurrencies.isEmpty)
    #expect(model.error != nil)
  }
}
