import Foundation
import WatchConnectivity

class WatchViewModel: NSObject, ObservableObject {
    var session: WCSession
    var api: JellyfishAPI = JellyfishAPI()
    
    @Published var lmLoaded = false
    @Published var balanceLoaded = false
    
    @Published var balance = [JellyfishToken]()
    @Published var lps = [JellyfishToken]()
    @Published var poolPairs = [JellyfishPoolPair]()
    
    @Published var publicKeysBTC = [String]()
    @Published var publicKeysDFI = [String]()
    
    enum WatchReceiveMethod: String {
        case receivePublicKeysDFI
        case receivePublicKeysBTC
    }
    
    enum WatchSendMethod: String {
        case loadData
    }
    
    init(session: WCSession = .default) {
        self.session = session
        self.balance = []
//        self.poolShares = []
        self.poolPairs = []
        
        if let keysBTC = UserDefaults.standard.object(forKey: "publicKeysBTC") as? Data {
            let decoder = JSONDecoder()
            if let cachedKeysBTC = try? decoder.decode([String].self, from: keysBTC) {
                self.publicKeysBTC = cachedKeysBTC
            }
        }
        
        if let keysDFI = UserDefaults.standard.object(forKey: "publicKeysDFI") as? Data {
            let decoder = JSONDecoder()
            if let cachedKeysDFI = try? decoder.decode([String].self, from: keysDFI) {
                self.publicKeysDFI = cachedKeysDFI
            }
        }
        
        super.init()
        
        self.session.delegate = self
        session.activate()
    }
    
    func sendDataMessage(for method: WatchSendMethod, data: [String: Any] = [:]) {
        sendMessage(for: method.rawValue, data: data)
    }
    
    func refreshPairsAndBalance() {
        self.api.requestPoolPairs { (pairs: [JellyfishPoolPair]) in
            self.poolPairs = pairs;
            
            self.api.requestDataForTokens(addresses: self.publicKeysDFI, completion: { (tokens: [JellyfishToken], lps: [JellyfishToken]) in
                self.balance = tokens
                self.lps = lps
                
                self.balanceLoaded = true
                self.lmLoaded = true
            })
        }
    }
}

extension WatchViewModel: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        debugPrint("activationDidCompleteWith activationState:\(activationState.rawValue), error: \(String(describing: error))")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            guard let method = message["method"] as? String, let enumMethod = WatchReceiveMethod(rawValue: method) else {
                return
            }
            switch enumMethod {
            case .receivePublicKeysDFI:
                let data = (message["data"] as? String) ?? ""
                let jsonData = data.data(using: .utf8)

                if (jsonData == nil) {
                    return
                }

                let jsonDecoder = JSONDecoder()
                let publicKeysDFI = try? jsonDecoder.decode([String].self, from: jsonData!)

                if (publicKeysDFI == nil) {
                    return
                }

                self.publicKeysDFI = publicKeysDFI!

                UserDefaults.standard.set(jsonData, forKey: "publicKeysDFI")
                UserDefaults.standard.synchronize()
                
                self.refreshPairsAndBalance();
                break;
            case .receivePublicKeysBTC:
                break;
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
        debugPrint("didReceiveApplicationContext: \(message)")

        DispatchQueue.main.async {
            for (method, applicationData) in message {
                guard let enumMethod = WatchReceiveMethod(rawValue: method) else {
                    continue
                }
                
                switch enumMethod {
                case .receivePublicKeysDFI:
                    let data = (applicationData as? String) ?? ""
                    let jsonData = data.data(using: .utf8)

                    if (jsonData == nil) {
                        return
                    }

                    let jsonDecoder = JSONDecoder()
                    let publicKeysDFI = try? jsonDecoder.decode([String].self, from: jsonData!)

                    if (publicKeysDFI == nil) {
                        return
                    }

                    self.publicKeysDFI = publicKeysDFI!

                    UserDefaults.standard.set(jsonData, forKey: "publicKeysDFI")
                    UserDefaults.standard.synchronize()
                    
                    self.refreshPairsAndBalance();
                    break;
                case .receivePublicKeysBTC:
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
