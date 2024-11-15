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
  var currency: Currency = .usd
  var cryptoCurrencies = [CryptoCurrency]()
  var error: Error?

  @ObservationIgnored
  @Dependency(\.apiClient.currency) var apiClient
  @ObservationIgnored
  @Dependency(\.continuousClock) var clock

  public init(destination: Destination? = nil) {
    self.destination = destination
  }

  // fetching the currencies concurrently, though there's an api limit

  //    func task() async {
  //      self.cryptoCurrencies = []
  //      do {
  //        self.currencies = try await withThrowingTaskGroup(of: CryptoCurrency.self) { taskGroup in
  //          var cryptoCurrencies = [CryptoCurrency]()
  //          for currency in Symbol.allCases {
  //            taskGroup.addTask {
  //              return try await self.apiClient(.fetch(currency))
  //            }
  //          }
  //          for try await currency in taskGroup {
  //            cryptoCurrencies.append(currency)
  //          }
  //          return currencies
  //        }
  //      } catch {}
  //    }

  func task() async {
    await fetchCurrencies()
  }

  func fetchCurrencies() async {
    self.error = nil
    self.cryptoCurrencies = []

    var symbols: [Symbol]
    switch self.currency {
    case .usd: symbols = [.btcusdt, .ethusdt, .ltcusdt]
    case .inr: symbols = [.btcinr, .ltcinr, .dogeinr]
    }

    do {
      for currencySymbol in symbols {
        cryptoCurrencies.append(try await self.apiClient(.fetch(currencySymbol)))
        // avoid api limit
        // Status: 429
        // Response: {"message":"Too many api request","code":2136}
        try await clock.sleep(for: .seconds(1))
      }
    } catch {
      self.error = error
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
    self.destination = .detail(
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
      if let _ = self.model.error {
        Button {
          Task { await self.model.fetchCurrencies() }
        } label: {
          Text("Retry")
        }
      } else {
        List {
          ForEach(self.model.cryptoCurrencies) { currency in
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
