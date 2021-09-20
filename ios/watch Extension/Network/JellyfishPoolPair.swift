import Foundation

class JellyfishPoolPairResponse: Codable {
    let data: [JellyfishPoolPair]

    init(data: [JellyfishPoolPair]) {
        self.data = data
    }
}

class JellyfishPoolPair: Identifiable, Codable {
    let id, symbol, name: String
    let status: Bool
    let tokenA, tokenB: Token
    let priceRatio: PriceRatio
    let commission: String
    let totalLiquidity: TotalLiquidity
    let tradeEnabled: Bool
    let ownerAddress, rewardPct: String
    let creation: Creation
    let apr: APR

    init(id: String, symbol: String, name: String, status: Bool, tokenA: Token, tokenB: Token, priceRatio: PriceRatio, commission: String, totalLiquidity: TotalLiquidity, tradeEnabled: Bool, ownerAddress: String, rewardPct: String, creation: Creation, apr: APR) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.status = status
        self.tokenA = tokenA
        self.tokenB = tokenB
        self.priceRatio = priceRatio
        self.commission = commission
        self.totalLiquidity = totalLiquidity
        self.tradeEnabled = tradeEnabled
        self.ownerAddress = ownerAddress
        self.rewardPct = rewardPct
        self.creation = creation
        self.apr = apr
    }
}

class APR: Codable {
    let reward, total: Double

    init(reward: Double, total: Double) {
        self.reward = reward
        self.total = total
    }
}

class Creation: Codable {
    let tx: String
    let height: Int

    init(tx: String, height: Int) {
        self.tx = tx
        self.height = height
    }
}

class PriceRatio: Codable {
    let ab, ba: String

    init(ab: String, ba: String) {
        self.ab = ab
        self.ba = ba
    }
}

class Token: Codable {
    let symbol, displaySymbol, id, reserve: String
    let blockCommission: String

    init(symbol: String, displaySymbol: String, id: String, reserve: String, blockCommission: String) {
        self.symbol = symbol
        self.displaySymbol = displaySymbol
        self.id = id
        self.reserve = reserve
        self.blockCommission = blockCommission
    }
}

class TotalLiquidity: Codable {
    let token, usd: String

    init(token: String, usd: String) {
        self.token = token
        self.usd = usd
    }
}
