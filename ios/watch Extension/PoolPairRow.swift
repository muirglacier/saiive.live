//
//  PoolPairRow.swift
//  watch Extension
//
//  Created by Dominik Pfaffenbauer on 16.09.21.
//

import SwiftUI

struct PoolPairRow: View {
    var pair: PoolPairLiquidity
    
    var body: some View {
        VStack (alignment: .leading) {
            IconPairView(tokenA: pair.tokenA, tokenB: pair.tokenB)
                .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .leading) {
                Text(pair.tokenA + " " + pair.tokenB).font(.headline)
                Text("\(Formattable.formatNumber(number: pair.apy, style: NumberFormatter.Style.percent, fraction: 2)) % APR")
                    .lineLimit(1)
                    .allowsTightening(true)
            }
            
            VStack(alignment: .leading) {
                Text(pair.tokenA).font(.headline)
                Text(Formattable.formatNumber(number: pair.totalLiquidityInUSDT, fraction: 2))
                    .lineLimit(1)
                    .allowsTightening(true)
                
            }
        }
    }
}
