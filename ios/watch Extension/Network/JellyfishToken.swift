import Foundation

class JellyfishTokenResponse: Codable {
    let data: [JellyfishToken]

    init(data: [JellyfishToken]) {
        self.data = data
    }
}

class JellyfishToken: Codable, Identifiable {
    let id, symbol, symbolKey: String
    var amount: String
    var amountUtxo: Double = 0;
    var amountTotal: Double = 0;
    var amountToken: Double = 0;
    let name: String
    let isDAT, isLPS: Bool
    let displaySymbol: String

    init(id: String, amount: String, symbol: String, symbolKey: String, name: String, isDAT: Bool, isLPS: Bool, displaySymbol: String) {
        self.id = id
        self.amount = amount
        self.symbol = symbol
        self.symbolKey = symbolKey
        self.name = name
        self.isDAT = isDAT
        self.isLPS = isLPS
        self.displaySymbol = displaySymbol
        
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, symbol, symbolKey, amount, name, isDAT, isLPS, displaySymbol
    }
}

class JellyfishBalance: Codable {
    let data: String

    init(data: String) {
        self.data = data
    }
}
