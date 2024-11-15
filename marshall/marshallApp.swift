import SwiftUI
import Dependencies
import ApiClientLive
import ListFeature
import Model

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

          // deep link to detail

          //          ListView(
          //            model: .init(
          //              destination: .detail(
          //                .init(
          //                  cryptoCurrency: CryptoCurrency(
          //                    symbol: "btcinr",
          //                    baseAsset: "btc",
          //                    quoteAsset: "INR",
          //                    openPrice: 5656600.0,
          //                    lowPrice: 5656600.0,
          //                    highPrice: 5656600.0,
          //                    lastPrice: 5656600.0,
          //                    volume: 0.0,
          //                    bidPrice: 0.0,
          //                    askPrice: 0.0,
          //                    at: Date(timeIntervalSince1970: 1727329628)
          //                  ),
          //                  currency: .usd
          //                )
          //              )
          //            )
          //          )
        }
      }
    }
  }
}
