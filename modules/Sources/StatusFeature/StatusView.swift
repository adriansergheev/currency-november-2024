import SwiftUI
import ApiClient
import Model
import Dependencies
import Styleguide

@MainActor
@Observable
public final class StatusModel: Identifiable {
  var status: SystemStatus?
  var isFetching: Bool = false

  @ObservationIgnored
  @Dependency(\.apiClient.status) var apiClient
  @ObservationIgnored
  @Dependency(\.continuousClock) var clock

  public init() {}

  func task() async {
    for await _ in clock.timer(interval: .seconds(1)) {
      await fetchStatus()
    }
  }

  private func fetchStatus() async {
    defer { self.isFetching = false }
    self.isFetching = true
    do {
      self.status = try await apiClient(.fetch)
    } catch {
      self.status = .init(message: error.localizedDescription)
    }
  }
}

public struct StatusView: View {
  let model: StatusModel

  public init(model: StatusModel) {
    self.model = model
  }

  public var body: some View {
    VStack {
      Spacer()

      if let status = model.status, !model.isFetching {
        VStack(spacing: .grid(3)) {
          Image(systemName: "checkmark.seal.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 80, height: 80)
            .foregroundColor(status.status == .normal ? .green : .orange)

          Text(status.message)
            .font(.title)
            .fontWeight(.semibold)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16)
          .fill(Color(.systemGray6)))
      } else {
        VStack(spacing: .grid(2)) {
          ProgressView()
          Text("Fetching Status…")
            .font(.body)
            .foregroundColor(.gray)
        }
      }
      Spacer()
    }
    .padding()
    .task {
      await model.task()
    }
  }
}

#Preview {
  StatusView(model: .init())
}
