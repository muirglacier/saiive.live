import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: WatchViewModel = WatchViewModel()
    
    var body: some View {
        if (viewModel.publicKeysDFI.count == 0) {
            Text("Please Initialize the saiive.live wallet on your iPhone")
                .navigationTitle("saiive.live")
        }
        else {
            TabView {
                VStack {
                    NavigationView {
                        List(viewModel.balance) { balance in
                            BalanceRow(balance: balance)
                        }
                    }
                    .navigationTitle("Balance")
                }
                VStack {
                    NavigationView {
                        List(viewModel.lps) { pair in
                            PoolShareRow(token: pair, pairs: viewModel.poolPairs)
                        }
                    }
                    .navigationTitle("Your LM")
                }
                VStack {
                    NavigationView {
                        List(viewModel.poolPairs) { pair in
                            PoolPairRow(pair: pair)
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
