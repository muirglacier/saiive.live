//
//  PoolShareRow.swift
//  watch Extension
//
//  Created by Dominik Pfaffenbauer on 16.09.21.
//

import SwiftUI

struct PoolShareRow: View {
    var pair: PoolShareLiquidity
    
    var body: some View {
        VStack (alignment: .leading) {
            IconPairView(tokenA: pair.tokenA, tokenB: pair.tokenB)
                .frame(maxWidth: .infinity, alignment: .center)
            
            HStack(alignment: .top) {
                Text("Share").font(.headline)
                Text("\(pair.poolSharePercentage) %")
                    .lineLimit(1)
                    .allowsTightening(true)
            }
            
            HStack(alignment: .top) {
                Text(pair.tokenA).font(.headline)
                Text(Formattable.formatNumber(number: pair.poolSharePercentage / 100 * pair.poolPair.reserveA, style: NumberFormatter.Style.decimal))
                    .lineLimit(1)
                    .allowsTightening(true)
            }
            
            HStack(alignment: .top) {
                Text(pair.tokenB).font(.headline)
                Text(Formattable.formatNumber(number: pair.poolSharePercentage / 100 * pair.poolPair.reserveB, style: NumberFormatter.Style.decimal))
                    .lineLimit(1)
                    .allowsTightening(true)
            }
        }

    }
}
