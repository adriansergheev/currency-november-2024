import SwiftUI
import Styleguide
import StatusFeature
import SwiftUINavigation
import Dependencies
import Model
import ApiClient

@MainActor
@Observable
public class ListModel {
  @CasePathable
  @dynamicMemberLookup
  enum Destination {
    case status(StatusModel)
  }

  var destination: Destination?
  var currencies = [CryptoCurrency]()

  enum Currency: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case inr, usd
  }

  var currency: Currency = .usd

  @ObservationIgnored
  @Dependency(\.apiClient.currency) var apiClient
  @ObservationIgnored
  @Dependency(\.continuousClock) var clock

  public init() {}

  // fetching the currencies concurrently results in:

  // Status: 429
  // Response: {"message":"Too many api request","code":2136}

  //    func task() async {
  //      self.currencies = []
  //      do {
  //        self.currencies = try await withThrowingTaskGroup(of: CryptoCurrency.self) { taskGroup in
  //          var currencies = [CryptoCurrency]()
  //          for currency in Symbol.allCases {
  //            taskGroup.addTask {
  //              return try await self.apiClient(.fetch(currency))
  //            }
  //          }
  //          for try await currency in taskGroup {
  //            currencies.append(currency)
  //          }
  //          return currencies
  //        }
  //      } catch {}
  //    }

  func task() async {
    await fetchCurrencies()
  }

  func fetchCurrencies() async {
    self.currencies = []

    var symbols: [Symbol]
    switch self.currency {
    case .usd: symbols = [.btcusdt, .ethusdt, .ltcusdt]
    case .inr: symbols = [.btcinr, .ltcinr, .dogeinr]
    }

    do {
      for currencySymbol in symbols {
        currencies.append(try await self.apiClient(.fetch(currencySymbol)))
        // avoid api limit
        try await clock.sleep(for: .seconds(1))
      }
    } catch {
      // TODO: Handle error
    }
  }

  func currencyRowTapped(_ currency: CryptoCurrency) {
    print("Tapped \(currency)")
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
}

public struct ListView: View {
  @State var model: ListModel

  public init(model: ListModel) {
    self.model = model
  }

  public var body: some View {
    List {
      ForEach(self.model.currencies) { currency in
        Button {
          self.model.currencyRowTapped(currency)
        } label: {
          HStack {
            Text("💰 \(currency.symbol.uppercased())")
              .font(.headline)
              .foregroundColor(.primary)

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
          ForEach(ListModel.Currency.allCases) { currency in
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
  }
}

#Preview {
  ListView(model: .init())
}
