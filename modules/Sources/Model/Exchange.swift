public struct Exchange: Decodable, Sendable {
  public let amount: Int
  public let base: String
  public let rates: [String: Double]

  public init(amount: Int, base: String, rates: [String : Double]) {
    self.amount = amount
    self.base = base
    self.rates = rates
  }
}
