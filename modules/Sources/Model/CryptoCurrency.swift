import Foundation

public struct CryptoCurrency: Decodable, Hashable, Identifiable, Sendable {
  public var id: String { symbol }

  public let symbol: String
  public let baseAsset: String
  public let quoteAsset: String
  public let openPrice: Double
  public let lowPrice: Double
  public let highPrice: Double
  public let lastPrice: Double
  public let volume: Double
  public let bidPrice: Double
  public let askPrice: Double
  public let at: Date

  enum CodingKeys: CodingKey {
    case symbol
    case baseAsset
    case quoteAsset
    case openPrice
    case lowPrice
    case highPrice
    case lastPrice
    case volume
    case bidPrice
    case askPrice
    case at
  }

  public init(from decoder: any Decoder) throws {
    func decodeDouble(_ string: String) throws -> Double {
      enum DecodingError: Error {
        case invalidDouble
      }
      if let double = Double(string) {
        return double
      } else {
        throw DecodingError.invalidDouble
      }
    }

    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.symbol = try container.decode(String.self, forKey: .symbol)
    self.baseAsset = try container.decode(String.self, forKey: .baseAsset)
    self.quoteAsset = try container.decode(String.self, forKey: .quoteAsset)

    self.openPrice = try decodeDouble(try container.decode(String.self, forKey: .openPrice))
    self.lowPrice = try decodeDouble(try container.decode(String.self, forKey: .lowPrice))
    self.highPrice = try decodeDouble(try container.decode(String.self, forKey: .highPrice))
    self.lastPrice = try decodeDouble(try container.decode(String.self, forKey: .lastPrice))
    self.volume = try decodeDouble(try container.decode(String.self, forKey: .volume))
    self.bidPrice = try decodeDouble(try container.decode(String.self, forKey: .bidPrice))
    self.askPrice = try decodeDouble(try container.decode(String.self, forKey: .askPrice))
    self.at = try container.decode(Date.self, forKey: .at)
  }

  public init(
    symbol: String,
    baseAsset: String,
    quoteAsset: String,
    openPrice: Double,
    lowPrice: Double,
    highPrice: Double,
    lastPrice: Double,
    volume: Double,
    bidPrice: Double,
    askPrice: Double,
    at: Date
  ) {
    self.symbol = symbol
    self.baseAsset = baseAsset
    self.quoteAsset = quoteAsset
    self.openPrice = openPrice
    self.lowPrice = lowPrice
    self.highPrice = highPrice
    self.lastPrice = lastPrice
    self.volume = volume
    self.bidPrice = bidPrice
    self.askPrice = askPrice
    self.at = at
  }

}

