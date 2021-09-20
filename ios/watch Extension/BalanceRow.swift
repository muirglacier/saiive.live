import SwiftUI

struct BalanceRow: View {
    var balance: JellyfishToken
    
    var body: some View {
        HStack {
            IconView(token: balance.symbolKey)
            
            VStack(alignment: .leading) {
                Text(balance.symbol).font(.headline)
                Text("\(balance.amount)")
                    .lineLimit(1)
                    .allowsTightening(true)
            }
        }
    }
}


struct BalanceRow_Previews: PreviewProvider {
    static var previews: some View {
        BalanceRow(balance:
            JellyfishToken(
                id: "DFI",
                amount: "100.000123",
                symbol: "DFI",
                symbolKey: "DFI",
                name: "DFI",
                isDAT: false,
                isLPS: false,
                displaySymbol: "DFI"
            )
        )
    }
}
