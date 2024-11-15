import SwiftUI
import Model
import DetailFeature

@main
struct DetailPreviewApp: App {
  var body: some Scene {
    WindowGroup {
      DetailView(
        model: .init(
          cryptoCurrency:  CryptoCurrency(
            symbol: "btcinr",
            baseAsset: "btc",
            quoteAsset: "INR",
            openPrice: 5656600.0,
            lowPrice: 5656600.0,
            highPrice: 5656600.0,
            lastPrice: 5656600.0,
            volume: 0.0,
            bidPrice: 0.0,
            askPrice: 0.0,
            date: Date(timeIntervalSince1970: 1727329628)
          ),
          currency: .inr
        )
      )
    }
  }
}
