import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: WatchViewModel = WatchViewModel()
    
    var body: some View {
        TabView {
            VStack {
                if (viewModel.balance.count == 0) {
                    Text("Please open the app on your iPhone and load the Balances")
                        .navigationTitle("saiive.live")
                }
                else {
                    NavigationView {
                        List(viewModel.balance) { balance in
                            BalanceRow(balance: balance)
                        }
                    }
                    .navigationTitle("Balance")
                }
            }
            VStack {
                if (viewModel.poolPairs.count == 0) {
                    Text("Please open the app on your iPhone and load the Pool Pairs")
                        .navigationTitle("Your LM")
                }
                else {
                    NavigationView {
                        List(viewModel.poolShares) { pair in
                            PoolShareRow(pair: pair)
                        }
                    }
                    .navigationTitle("Your LM")
                    .onAppear(perform: viewModel.requestData)
                }
            }
            VStack {
                if (viewModel.poolPairs.count == 0) {
                    Text("Please open the app on your iPhone and load the Pool Pairs")
                        .navigationTitle("saiive.live")
                }
                else {
                    NavigationView {
                        List(viewModel.poolPairs) { pair in
                            PoolPairRow(pair: pair)
                        }
                    }
                    .navigationTitle("Pool Pairs")
                    .onAppear(perform: viewModel.requestData)
                }
            }
            .onAppear(perform: viewModel.requestData)
        }
    }
}
