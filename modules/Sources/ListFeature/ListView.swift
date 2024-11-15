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

  @ObservationIgnored
  @Dependency(\.apiClient.currency) var apiClient
  @ObservationIgnored
  @Dependency(\.continuousClock) var clock

  public init() {}

  // fetching the currencies concurrently results in:

  // Status: 429
  // Response: {"message":"Too many api request","code":2136}

//    func task() async {
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
    do {
      for currencySymbol in Symbol.allCases {
        currencies.append(try await self.apiClient(.fetch(currencySymbol)))
        // avoid api limit
        try await clock.sleep(for: .seconds(1))
      }
    } catch {
      //TODO: Handle error
    }
  }

  func currencyTapped(_ currency: CryptoCurrency) {
    print("Tapped \(currency)")
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
          self.model.currencyTapped(currency)
        } label: {
          Text(currency.symbol)
        }
      }
    }
    .task {
      await self.model.task()
    }
    .toolbar {
      Button {
        model.openStatusButtonTapped()
      } label: {
        HStack {
          Text("Status")
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
