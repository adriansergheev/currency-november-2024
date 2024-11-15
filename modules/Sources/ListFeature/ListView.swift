import SwiftUI
import Styleguide
import StatusFeature
import SwiftUINavigation
import Dependencies
import Model
import ApiClient
import DetailFeature

@MainActor
@Observable
public class ListModel {
  @CasePathable
  @dynamicMemberLookup
  public enum Destination {
    case status(StatusModel)
    case detail(DetailModel)
  }

  var destination: Destination?
  var isLoading: Bool = false
  var currency: Currency = .usd
  var cryptoCurrencies = [CryptoCurrency]()
  var error: Error?

  @ObservationIgnored
  @Dependency(\.apiClient) var apiClient
  @ObservationIgnored
  @Dependency(\.continuousClock) var clock

  public init(destination: Destination? = nil) {
    self.destination = destination
  }

  func task() async {
    await fetchCurrencies()
  }

  func fetchCurrencies() async {
    isLoading = true
    defer { isLoading = false }
    error = nil
    cryptoCurrencies = []

    var symbols: [Symbol]
    switch currency {
    case .usd, .sek: symbols = [.btcusdt, .ethusdt, .ltcusdt]
    case .inr: symbols = [.btcinr, .ltcinr, .dogeinr]
    }

    func fetch() async -> [CryptoCurrency] {
      var currencies = [CryptoCurrency]()
      do {
        for currencySymbol in symbols {
          currencies.append(try await self.apiClient.currency(.fetch(currencySymbol)))
          // avoid api limit
          // Status: 429
          // Response: {"message":"Too many api request","code":2136}
          try await clock.sleep(for: .seconds(1))
        }
      } catch {
        self.error = error
      }
      return currencies
    }

    switch currency {
    case .sek:
      async let exchange = self.apiClient.exchange(.fetch)
      async let currencies = fetch()

      if let rate = try? await exchange.rates["SEK"] {
        self.cryptoCurrencies = await currencies.map { currency in
          CryptoCurrency(
            symbol: currency.symbol,
            baseAsset: currency.baseAsset,
            quoteAsset: "USD",
            openPrice: currency.openPrice * rate,
            lowPrice: currency.lowPrice * rate,
            highPrice: currency.highPrice * rate,
            lastPrice: currency.lastPrice * rate,
            volume: currency.volume,
            bidPrice: currency.bidPrice * rate,
            askPrice: currency.askPrice * rate,
            date: currency.date
          )
        }
      } else {
        //TODO: Proper error
        self.error = NSError() as Error
      }

    case .inr, .usd:
      self.cryptoCurrencies = await fetch()
    }

  }

  func changeCurrencyMenuButtonTapped(_ currency: Currency) async {
    self.currency = currency
    await fetchCurrencies()
  }

  func openStatusButtonTapped() {
    destination = .status(.init())
  }

  func dismissStatusButtonTapped() {
    destination = nil
  }

  func currencyRowTapped(_ cryptoCurrency: CryptoCurrency) {
    destination = .detail(
      .init(
        cryptoCurrency: cryptoCurrency,
        currency: self.currency
      )
    )
  }
  func dismissDetailButtonTapped() {
    destination = nil
  }
}

public struct ListView: View {
  @State var model: ListModel

  public init(model: ListModel) {
    self.model = model
  }

  public var body: some View {
    Group {
      if let _ = model.error {
        Button {
          Task { await model.fetchCurrencies() }
        } label: {
          Text("Retry")
        }
      } else if model.isLoading {
        ProgressView()
      } else {
        List {
          ForEach(model.cryptoCurrencies) { currency in
            Button {
              self.model.currencyRowTapped(currency)
            } label: {
              HStack {
                Text("💰 \(currency.symbol.uppercased())")
                  .foregroundColor(.primary)
                  .font(.headline)

                Spacer()

                VStack(alignment: .trailing) {
                  Text("Last: \(currency.lastPrice.formatted(.currency(code: self.model.currency.rawValue)))")
                    .font(.subheadline)
                    .foregroundColor(currency.lastPrice >= currency.openPrice ? .green : .red)
                  Text("High: \(currency.highPrice.formatted(.currency(code: self.model.currency.rawValue)))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
              }
              .padding(.vertical, .grid(1))
            }
          }
        }
      }
    }
    .task {
      await self.model.task()
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          model.openStatusButtonTapped()
        } label: {
          HStack {
            Label("Status", systemImage: "info.circle")
          }
        }
      }
      ToolbarItem(placement: .topBarLeading) {
        Menu {
          ForEach(Currency.allCases) { currency in
            Button(currency.rawValue.uppercased()) {
              Task { await self.model.changeCurrencyMenuButtonTapped(currency) }
            }
          }
        } label: {
          Label("Currency", systemImage: "arrow.2.circlepath")
        }
      }
    }
    .navigationTitle("Currencies")
    .sheet(item: $model.destination.status) { model in
      NavigationStack {
        StatusView(model: model)
          .toolbar {
            ToolbarItem(placement: .cancellationAction) {
              Button("Dismiss") {
                self.model.dismissStatusButtonTapped()
              }
            }
          }
      }
    }
    .sheet(item: $model.destination.detail) { model in
      NavigationStack {
        DetailView(model: model)
          .toolbar {
            ToolbarItem(placement: .cancellationAction) {
              Button("Dismiss") {
                self.model.dismissDetailButtonTapped()
              }
            }
          }
      }
    }
  }
}

#Preview {
  ListView(model: .init())
}
