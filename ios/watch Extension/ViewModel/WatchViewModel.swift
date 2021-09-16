import Foundation
import WatchConnectivity

class WatchViewModel: NSObject, ObservableObject {
    var session: WCSession
    @Published var balance = [Balance]()
    @Published var poolShares = [PoolShareLiquidity]()
    @Published var poolPairs = [PoolPairLiquidity]()
    
    // Add more cases if you have more receive method
    enum WatchReceiveMethod: String {
        case receiveBalance
        case receivePoolShares
        case receivePoolPairs
    }
    
    // Add more cases if you have more sending method
    enum WatchSendMethod: String {
        case loadBalance
        case loadLiquidity
    }
    
    init(session: WCSession = .default) {
        self.session = session
        self.balance = []
        self.poolShares = []
        self.poolPairs = []
        
        if let cachedBalance = UserDefaults.standard.object(forKey: "cachedBalance") as? Data {
            let decoder = JSONDecoder()
            if let loadedBalance = try? decoder.decode([Balance].self, from: cachedBalance) {
                self.balance = loadedBalance
            }
        }
        
        if let cachedPoolPairs = UserDefaults.standard.object(forKey: "cachedPoolPairs") as? Data {
            let decoder = JSONDecoder()
            if let loadedPoolPairs = try? decoder.decode([PoolPairLiquidity].self, from: cachedPoolPairs) {
                self.poolPairs = loadedPoolPairs
            }
        }
        
        if let cachedPoolShares = UserDefaults.standard.object(forKey: "cachedPoolShares") as? Data {
            let decoder = JSONDecoder()
            if let loadedPoolShares = try? decoder.decode([PoolShareLiquidity].self, from: cachedPoolShares) {
                self.poolShares = loadedPoolShares
            }
        }
        
        super.init()
        
        self.session.delegate = self
        session.activate()
    }
    
    func requestData() {
        sendDataMessage(for: .loadBalance)
        sendDataMessage(for: .loadLiquidity)
    }
    
    func sendDataMessage(for method: WatchSendMethod, data: [String: Any] = [:]) {
        sendMessage(for: method.rawValue, data: data)
    }
    
}

class Balance: Codable, Identifiable {
    let mixedAccount: Bool?
    let token: String
    let balance: Int
    let balanceDisplay: Double
    let isLPS, isDAT: Bool
    let additionalDisplay, tokenDisplay: String
    let utxoBalance, tokenBalance: Int?
    let utxoBalanceDisplay, tokenBalanceDisplay: Double?

    init(mixedAccount: Bool?, token: String, balance: Int, balanceDisplay: Double, isLPS: Bool, isDAT: Bool, additionalDisplay: String, tokenDisplay: String, utxoBalance: Int?, tokenBalance: Int?, utxoBalanceDisplay: Double?, tokenBalanceDisplay: Double?) {
        self.mixedAccount = mixedAccount
        self.token = token
        self.balance = balance
        self.balanceDisplay = balanceDisplay
        self.isLPS = isLPS
        self.isDAT = isDAT
        self.additionalDisplay = additionalDisplay
        self.tokenDisplay = tokenDisplay
        self.utxoBalance = utxoBalance
        self.tokenBalance = tokenBalance
        self.utxoBalanceDisplay = utxoBalanceDisplay
        self.tokenBalanceDisplay = tokenBalanceDisplay
    }
    
    var id: String {
        return tokenDisplay
    }
}

class PoolShareLiquidity: Codable, Identifiable {
    let tokenA, tokenB: String
    let poolPair: PoolPair
    let totalLiquidityInUSDT, yearlyPoolReward, poolSharePercentage, apy: Double
    let coin: Coin
    let blockReward, minuteReward, hourlyReword, dailyReward: Double
    let yearlyReward, blockRewardFiat, minuteRewardFiat, hourlyRewordFiat: Double
    let dailyRewardFiat, yearlyRewardFiat: Double

    init(tokenA: String, tokenB: String, poolPair: PoolPair, totalLiquidityInUSDT: Double, yearlyPoolReward: Double, poolSharePercentage: Double, apy: Double, coin: Coin, blockReward: Double, minuteReward: Double, hourlyReword: Double, dailyReward: Double, yearlyReward: Double, blockRewardFiat: Double, minuteRewardFiat: Double, hourlyRewordFiat: Double, dailyRewardFiat: Double, yearlyRewardFiat: Double) {
        self.tokenA = tokenA
        self.tokenB = tokenB
        self.poolPair = poolPair
        self.totalLiquidityInUSDT = totalLiquidityInUSDT
        self.yearlyPoolReward = yearlyPoolReward
        self.poolSharePercentage = poolSharePercentage
        self.apy = apy
        self.coin = coin
        self.blockReward = blockReward
        self.minuteReward = minuteReward
        self.hourlyReword = hourlyReword
        self.dailyReward = dailyReward
        self.yearlyReward = yearlyReward
        self.blockRewardFiat = blockRewardFiat
        self.minuteRewardFiat = minuteRewardFiat
        self.hourlyRewordFiat = hourlyRewordFiat
        self.dailyRewardFiat = dailyRewardFiat
        self.yearlyRewardFiat = yearlyRewardFiat
    }
    
    var id: String {
        return tokenA + tokenB
    }

}

class Coin: Codable, Identifiable {
    let coin, idToken: String
    let fiat: Double
    let currency: String

    init(coin: String, idToken: String, fiat: Double, currency: String) {
        self.coin = coin
        self.idToken = idToken
        self.fiat = fiat
        self.currency = currency
    }
    
    var id: String {
        return idToken
    }
}

class PoolPair: Codable, Identifiable {
    let id, symbol, name: String
    let status: Bool
    let idTokenA, idTokenB: String
    let reserveA, reserveB, commission, totalLiquidity: Double
    let reserveADivReserveB, reserveBDivReserveA: Double
    let tradeEnabled: Bool
    let ownerAddress: String
    let blockCommissionA, blockCommissionB: Int
    let rewardPct: Double
    let creationTx: String
    let creationHeight: Int

    init(id: String, symbol: String, name: String, status: Bool, idTokenA: String, idTokenB: String, reserveA: Double, reserveB: Double, commission: Double, totalLiquidity: Double, reserveADivReserveB: Double, reserveBDivReserveA: Double, tradeEnabled: Bool, ownerAddress: String, blockCommissionA: Int, blockCommissionB: Int, rewardPct: Double, creationTx: String, creationHeight: Int) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.status = status
        self.idTokenA = idTokenA
        self.idTokenB = idTokenB
        self.reserveA = reserveA
        self.reserveB = reserveB
        self.commission = commission
        self.totalLiquidity = totalLiquidity
        self.reserveADivReserveB = reserveADivReserveB
        self.reserveBDivReserveA = reserveBDivReserveA
        self.tradeEnabled = tradeEnabled
        self.ownerAddress = ownerAddress
        self.blockCommissionA = blockCommissionA
        self.blockCommissionB = blockCommissionB
        self.rewardPct = rewardPct
        self.creationTx = creationTx
        self.creationHeight = creationHeight
    }
}

class PoolPairLiquidity: Codable, Identifiable {
    let tokenA, tokenB: String
    let poolPair: PoolPair
    let totalLiquidityInUSDT, yearlyPoolReward: Double
    let poolSharePercentage: Double?
    let apy: Double

    init(tokenA: String, tokenB: String, poolPair: PoolPair, totalLiquidityInUSDT: Double, yearlyPoolReward: Double, poolSharePercentage: Double?, apy: Double) {
        self.tokenA = tokenA
        self.tokenB = tokenB
        self.poolPair = poolPair
        self.totalLiquidityInUSDT = totalLiquidityInUSDT
        self.yearlyPoolReward = yearlyPoolReward
        self.poolSharePercentage = poolSharePercentage
        self.apy = apy
    }
}

extension WatchViewModel: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            guard let method = message["method"] as? String, let enumMethod = WatchReceiveMethod(rawValue: method) else {
                return
            }
            //
            //            switch enumMethod {
            //            case .receiveBalance:
            //                let data = (message["data"] as? String) ?? ""
            //                let jsonData = data.data(using: .utf8)
            //
            //                if (jsonData == nil) {
            //                    return
            //                }
            //
            //                let jsonDecoder = JSONDecoder()
            //                let balances = try? jsonDecoder.decode([Balance].self, from: jsonData!)
            //
            //                if (balances == nil) {
            //                    return
            //                }
            //
            //                self.balance = balances!
            //            }
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext message: [String : Any]) {
        DispatchQueue.main.async {
            for (method, applicationData) in message {
                guard let enumMethod = WatchReceiveMethod(rawValue: method) else {
                    continue
                }
                
                switch enumMethod {
                case .receiveBalance:
                    let data = (applicationData as? String) ?? ""
                    let jsonData = data.data(using: .utf8)
                    
                    if (jsonData == nil) {
                        return
                    }
                    
                    let jsonDecoder = JSONDecoder()
                    let balances = try? jsonDecoder.decode([Balance].self, from: jsonData!)
                    
                    if (balances == nil) {
                        return
                    }
                    
                    self.balance = balances!
                    
                    UserDefaults.standard.set(jsonData, forKey: "cachedBalance")
                    UserDefaults.standard.synchronize()
                    break;
                case .receivePoolShares:
                    let data = (applicationData as? String) ?? ""
                    let jsonData = data.data(using: .utf8)
                    
                    if (jsonData == nil) {
                        return
                    }
                    
                    let jsonDecoder = JSONDecoder()
                    let balances = try? jsonDecoder.decode([PoolShareLiquidity].self, from: jsonData!)
                    
                    if (balances == nil) {
                        return
                    }
                    
                    self.poolShares = balances!
                    
                    UserDefaults.standard.set(jsonData, forKey: "cachedPoolShares")
                    UserDefaults.standard.synchronize()
                    break;
                case .receivePoolPairs:
                    let data = (applicationData as? String) ?? ""
                    let jsonData = data.data(using: .utf8)
                    
                    if (jsonData == nil) {
                        return
                    }
                    
                    let jsonDecoder = JSONDecoder()
                    let balances = try? jsonDecoder.decode([PoolPairLiquidity].self, from: jsonData!)
                    
                    if (balances == nil) {
                        return
                    }
                    
                    self.poolPairs = balances!
                    
                    UserDefaults.standard.set(jsonData, forKey: "cachedPoolPairs")
                    UserDefaults.standard.synchronize()
                    break;
                }
            }
        }
    }
    
    func sendMessage(for method: String, data: [String: Any] = [:]) {
        guard session.isReachable else {
            return
        }
        let messageData: [String: Any] = ["method": method, "data": data]
        session.sendMessage(messageData, replyHandler: nil, errorHandler: nil)
    }
    
}
