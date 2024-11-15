import Testing
import Dependencies
import ApiClient
@testable import StatusFeature

@MainActor
@Suite
struct StatusTests {

  @Test func timer() async throws {
    let clock = TestClock()
    var apiClient = ApiClient.testValue

    apiClient.status = { _ in
      try? await clock.sleep(for: .seconds(1))
      return .init(message: "Test Status")
    }

    let model = withDependencies {
      $0.continuousClock = clock
      $0.apiClient = apiClient
    } operation: {
      StatusModel()
    }

    let task = Task {
      await model.task()
    }

    // kick-start, see:
    // https://forums.swift.org/t/reliably-testing-code-that-adopts-swift-concurrency/57304
    try await Task.sleep(for: .milliseconds(100))

    await clock.advance(by: .seconds(3))
    #expect(model.isFetching == true)
    await clock.advance(by: .seconds(1))
    #expect(model.isFetching == false)
    #expect(model.status != nil)
    task.cancel()
  }

}
