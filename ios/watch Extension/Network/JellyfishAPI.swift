import Foundation
import UIKit
import Alamofire

class JellyfishAPI
{
    func requestDataForToken(address: String, completion: @escaping ([JellyfishToken]?) -> Void) {
        AF.request("https://ocean.defichain.com/v0/mainnet/address/\(address)/tokens")
          .validate()
          .responseDecodable(of: JellyfishTokenResponse.self) { (response) in
//            guard let token = response.value?.data else { return }
//            completion(token)
            
            switch response.result {
                case .success(let result):
                    completion(result.data)
                case .failure(let error):
                    completion(nil)
                }
          }
    }
    
    func requestBalanceForAddress(address: String, completion: @escaping (JellyfishBalance?) -> Void) {
        AF.request("https://ocean.defichain.com/v0/mainnet/address/\(address)/balance")
          .validate()
          .responseDecodable(of: JellyfishBalance.self) { (response) in
//            guard let token = response.value?.data else { return }
//            completion(token)
            
            switch response.result {
                case .success(let result):
                    completion(result)
                case .failure(let error):
                    completion(nil)
                }
          }
    }
    
    func requestDataForTokens(addresses: [String], completion: @escaping ([JellyfishToken], [JellyfishToken]) -> Void) {
        let tokenDispatchGroup = DispatchGroup();
        var results: [String: [JellyfishToken]] = [:];
        var balanceResults: [String: JellyfishBalance] = [:];
        var combinedResults: [JellyfishToken] = [];
    
        addresses.forEach { address in
            tokenDispatchGroup.enter()
            tokenDispatchGroup.enter()
            
            self.requestDataForToken(address: address) { (tokens: [JellyfishToken]?) in
                tokenDispatchGroup.leave()
                
                if (nil == tokens) {
                    return
                }
                
                results[address] = tokens;
            }
            
            self.requestBalanceForAddress(address: address) { (balance: JellyfishBalance?) in
                tokenDispatchGroup.leave()
                
                if (nil == balance) {
                    return
                }
                
                if (Double(balance!.data) ?? 0 > 0) {
                    balanceResults[address] = balance;
                }
            }
        }
        
        tokenDispatchGroup.notify(queue: .main) {
            var utxo: Double = 0;
            
            balanceResults.forEach { (arg0) in
                let (_, value) = arg0
                
                utxo += Double(value.data) ?? 0
            }
            
            results.forEach { (arg0) in
                let (_, value) = arg0
                value.forEach { tokenA in
                    let existingToken = combinedResults.first { (tokenB: JellyfishToken) -> Bool in
                        return tokenA.id == tokenB.id
                    }
                    
                    if (nil != existingToken) {
                        let doubleAmountA: Double = Double(tokenA.amount) ?? 0;
                        let doubleAmountB = Double(existingToken!.amount) ?? 0;
                
                        existingToken!.amount = String(doubleAmountA + doubleAmountB);
                    }
                    else {
                        combinedResults.append(tokenA);
                    }
                }
            }
            
            combinedResults.forEach { (token: JellyfishToken) in
                token.amountTotal = Double(token.amount) ?? 0
                token.amountToken = Double(token.amount) ?? 0
            }
            
            let dfiToken = combinedResults.first { (token: JellyfishToken) -> Bool in
                return token.symbol == "DFI"
            }
            
            if (dfiToken != nil) {
                dfiToken!.amountUtxo = utxo
                dfiToken!.amountTotal = dfiToken!.amountUtxo + dfiToken!.amountToken
                dfiToken!.amount = String(dfiToken!.amountTotal)
            }
            else {
                let newDfiToken = JellyfishToken(
                    id: "DFI",
                    amount: String(utxo),
                    symbol: "DFI",
                    symbolKey: "DFI",
                    name: "DFI",
                    isDAT: false,
                    isLPS: false,
                    displaySymbol: "DFI"
                )
                
                newDfiToken.amountUtxo = utxo
                newDfiToken.amountTotal = utxo
                
                combinedResults.append(newDfiToken)
            }
            
            let lpsTokens: [JellyfishToken] = combinedResults.filter { (token: JellyfishToken) -> Bool in
                return token.isLPS
            };
            
            completion(combinedResults, lpsTokens);
        }
    }
     
    func requestPoolPairs(completion: @escaping ([JellyfishPoolPair]) -> Void) {
        AF.request("https://ocean.defichain.com/v0/mainnet/poolpairs")
          .validate()
          .responseDecodable(of: JellyfishPoolPairResponse.self) { (response) in
            guard let pairs = response.value?.data else { return }
            completion(pairs)
          }

    }
}
