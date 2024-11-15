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
    var clock = TestClock()
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
