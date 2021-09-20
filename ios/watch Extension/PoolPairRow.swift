//
//  PoolPairRow.swift
//  watch Extension
//
//  Created by Dominik Pfaffenbauer on 16.09.21.
//

import SwiftUI

struct PoolPairRow: View {
    var pair: JellyfishPoolPair
    
    var body: some View {
        VStack (alignment: .leading) {
            IconPairView(tokenA: pair.tokenA.symbol, tokenB: pair.tokenB.symbol)
                .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .leading) {
                Text(pair.tokenA.displaySymbol + " " + pair.tokenB.displaySymbol).font(.headline)
                Text("\(Formattable.formatNumber(number: pair.apr.total, style: NumberFormatter.Style.percent, fraction: 2)) % APR")
                    .lineLimit(1)
                    .allowsTightening(true)
            }
            
            VStack(alignment: .leading) {
                Text(pair.tokenA.displaySymbol).font(.headline)
                Text("\(Formattable.formatNumber(number: Double(pair.totalLiquidity.usd) ?? 0, fraction: 2))")
                    .lineLimit(1)
                    .allowsTightening(true)
                
            }
        }
    }
}


struct PoolPairRow_Previews: PreviewProvider {
    static var previews: some View {
        PoolPairRow(pair:
            JellyfishPoolPair(
                id: "5",
                symbol: "BTC-DFI",
                name: "Bitcoin-Default Defi token",
                status: true,
                tokenA: Token(
                    symbol: "BTC",
                    displaySymbol: "dBTC",
                    id: "2",
                    reserve: "2948.59269391",
                    blockCommission: "0"
                ),
                tokenB: Token(
                    symbol: "DFI",
                    displaySymbol: "DFI",
                    id: "0",
                    reserve: "51719336.46762386",
                    blockCommission: "0"
                ),
                priceRatio: PriceRatio(
                    ab: "0.00005701",
                    ba: "17540.3461368"
                ),
                commission: "0.002",
                totalLiquidity: TotalLiquidity(
                    token: "390488.09053699",
                    usd: "277364178.2976387172684884"
                ),
                tradeEnabled: true,
                ownerAddress: "8UAhRuUFCyFUHEPD7qvtj8Zy2HxF5HH5nb",
                rewardPct: "0.775945",
                creation: Creation(
                    tx: "f3c99e199d0157b2b6254cf3a51bb1171569ad5c4beb797e957d245aec194d38",
                    height: 466826
                ),
                apr: APR(
                    reward: 0.6993110319989186,
                    total: 0.6993110319989186
                )
            )
        )
    }
}
