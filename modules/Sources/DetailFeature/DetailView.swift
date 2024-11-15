import SwiftUI
import Model
import Styleguide

public struct DetailModel: Identifiable {
  public var id: String { cryptoCurrency.id }

  let cryptoCurrency: CryptoCurrency
  let currency: Currency

  public init(cryptoCurrency: CryptoCurrency, currency: Currency) {
    self.cryptoCurrency = cryptoCurrency
    self.currency = currency
  }
}

public struct DetailView: View {
  let model: DetailModel

  public init(model: DetailModel) {
    self.model = model
  }

  public var body: some View {
    VStack(spacing: .grid(5)) {
      Text("📊 \(model.cryptoCurrency.baseAsset.uppercased()) / \(model.cryptoCurrency.quoteAsset.uppercased())")
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding()

      VStack(spacing: .grid(2)) {
        HStack {
          Text("🚪 Open:")
          Spacer()
          Text("\(model.cryptoCurrency.openPrice, format: .currency(code: model.currency.rawValue))")
        }
        .font(.headline)

        HStack {
          Text("🔴 Low:")
          Spacer()
          Text("\(model.cryptoCurrency.lowPrice, format: .currency(code: model.currency.rawValue))")
        }
        .font(.headline)
        .foregroundColor(.red)

        HStack {
          Text("🟢 High:")
          Spacer()
          Text("\(model.cryptoCurrency.highPrice, format: .currency(code: model.currency.rawValue))")
        }
        .font(.headline)
        .foregroundColor(.green)

        HStack {
          Text("💵 Last:")
          Spacer()
          Text("\(model.cryptoCurrency.lastPrice, format: .currency(code: model.currency.rawValue))")
        }
        .font(.headline)
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 12).fill(
          Color(.systemGray6)
        )
      )

      VStack(spacing: .grid(2)) {
        HStack {
          Text("📉 Volume:")
          Spacer()
          Text("\(model.cryptoCurrency.volume, format: .number)")
        }
        .font(.subheadline)

        HStack {
          Text("📈 Bid:")
          Spacer()
          Text("\(model.cryptoCurrency.bidPrice, format: .currency(code: model.currency.rawValue))")
        }
        .font(.subheadline)

        HStack {
          Text("📈 Ask:")
          Spacer()
          Text("\(model.cryptoCurrency.askPrice, format: .currency(code: model.currency.rawValue))")
        }
        .font(.subheadline)
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(Color(.systemGray6))
      )

      Text("📅 Updated on \(model.cryptoCurrency.at.formatted(date: .abbreviated, time: .shortened))")
        .font(.footnote)
        .foregroundColor(.gray)
        .padding(.top)
    }
    .padding()
  }
}

#Preview {
  DetailView(
    model: .init(
      cryptoCurrency: CryptoCurrency(
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
        at: Date(timeIntervalSince1970: 1727329628)
      ),
      currency: .inr
    )
  )
}
