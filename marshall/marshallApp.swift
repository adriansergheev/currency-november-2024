import SwiftUI
import Dependencies
import ApiClientLive
import ListFeature

@main
struct marshallApp: App {
  var body: some Scene {
    WindowGroup {
      withDependencies {
        $0.apiClient = .liveValue
      } operation: {
        NavigationStack {
          ListView(model: .init())

          // deep link to status

          //          ListView(
          //            model: .init(
          //              destination: .status(
          //                .init()
          //              )
          //            )
          //          )
        }
      }
    }
  }
}
