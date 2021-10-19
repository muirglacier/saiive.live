import UIKit
import Flutter
import WatchConnectivity

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var session: WCSession?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        initFlutterChannel()
        if WCSession.isSupported() {
            session = WCSession.default;
            session?.delegate = self;
            session?.activate();
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func initFlutterChannel() {
        if let controller = window?.rootViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(
                name: "at.saiive.live.defi",
                binaryMessenger: controller.binaryMessenger)
            
            channel.setMethodCallHandler({ [weak self] (
                call: FlutterMethodCall,
                result: @escaping FlutterResult) -> Void in
                
                guard let watchSession = self?.session, watchSession.isPaired,
                      watchSession.isReachable, let methodData = call.arguments as? [String: Any],
                      let method = methodData["method"], let data = methodData["data"] as Any? else {
                    result(false)
                    
                    return
                }
                
                switch call.method {
                case "message":
                    let watchData: [String: Any] = ["method": method, "data": data]
                    watchSession.sendMessage(watchData, replyHandler: nil, errorHandler: nil)
                    result(true)
                case "applicationContext":
                    var ctx = WCSession.default.applicationContext
                    ctx[method as! String] = data
                    
                    do {
                        try watchSession.updateApplicationContext(["test": "test"])
                    } catch {
                        debugPrint(error)
                    }
                    
                    result(true)
                default:
                    result(FlutterMethodNotImplemented)
                }
            })
        }
    }
}


extension AppDelegate: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let method = message["method"] as? String, let controller = self.window?.rootViewController as? FlutterViewController {
                let channel = FlutterMethodChannel(
                    name: "at.saiive.live.defi",
                    binaryMessenger: controller.binaryMessenger)
                channel.invokeMethod(method, arguments: message)
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            if let method = applicationContext["method"] as? String, let controller = self.window?.rootViewController as? FlutterViewController {
                let channel = FlutterMethodChannel(
                    name: "at.saiive.live.defi",
                    binaryMessenger: controller.binaryMessenger)
                channel.invokeMethod(method, arguments: applicationContext)
            }
        }
    }
}
