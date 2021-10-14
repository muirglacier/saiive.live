import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: WatchViewModel = WatchViewModel()
    
    var body: some View {
        if (viewModel.publicKeysDFI.count == 0) {
            Text("Please Initialize the saiive.live DeFi Wallet on your iPhone")
                .navigationTitle("saiive.live")
        }
        else {
            TabView {
                VStack {
                    NavigationView {
                        if (!viewModel.balanceLoaded) {
                            Text("Loading")
                        }
                        else {
                            List(viewModel.balance) { balance in
                                BalanceRow(balance: balance)
                            }
                        }
                    }
                    .navigationTitle("Balance")
                }
                VStack {
                    NavigationView {
                        if (!viewModel.lmLoaded) {
                            Text("Loading")
                        }
                        else if (viewModel.lps.count == 0) {
                            Text("You don't have LM")
                        }
                        else {
                            List(viewModel.lps) { pair in
                                PoolShareRow(token: pair, pairs: viewModel.poolPairs)
                            }
                        }
                    }
                    .navigationTitle("Your LM")
                }
                VStack {
                    NavigationView {
                        if (!viewModel.lmLoaded) {
                            Text("Loading")
                        }
                        else {
                            List(viewModel.poolPairs) { pair in
                                PoolPairRow(pair: pair)
                            }
                        }
                    }
                    .navigationTitle("Pool Pairs")
                }
            }.onAppear(perform: {
                viewModel.refreshPairsAndBalance()
            })
        }
    }
}
