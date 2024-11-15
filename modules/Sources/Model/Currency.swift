import Foundation

public enum Currency: String, CaseIterable, Identifiable {
  public var id: String { self.rawValue }
  case inr, usd
}
