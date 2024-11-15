import SwiftUI
import Styleguide
import StatusFeature
import SwiftUINavigation

@MainActor
@Observable
public class ListModel {
  @CasePathable
  @dynamicMemberLookup
  enum Destination {
    case status(StatusModel)
  }

  var destination: Destination?

  public init() {}


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
    VStack {
      Text("Hello, World!")
    }
    .toolbar {
      Button {
        model.openStatusButtonTapped()
      } label: {
        Image(systemName: "checkmark.seal.fill")
          .tint(.gray)
      }
    }
    .navigationTitle("List")
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
