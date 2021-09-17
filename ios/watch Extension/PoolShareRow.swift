//
//  PoolShareRow.swift
//  watch Extension
//
//  Created by Dominik Pfaffenbauer on 16.09.21.
//

import SwiftUI

struct PoolShareRow: View {
    var token: JellyfishToken
    var pairs: [JellyfishPoolPair]
    
    var body: some View {
        VStack (alignment: .leading) {
            let pair = pairs.first { (pair: JellyfishPoolPair) -> Bool in
                return pair.symbol == token.symbol
            }
            
            if (pair != nil) {
                IconPairView(tokenA: pair!.tokenA.symbol, tokenB: pair!.tokenB.symbol)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                HStack(alignment: .top) {
                    Text("Share").font(.headline)
                    Text("\((token.amountTotal * 100) / (Double(pair!.totalLiquidity.token) ?? 1)) %")
                        .lineLimit(1)
                        .allowsTightening(true)
                }
                
                HStack(alignment: .top) {
                    Text(token.displaySymbol).font(.headline)
                    Text(Formattable.formatNumber(number: token.amountTotal, style: NumberFormatter.Style.decimal))
                        .lineLimit(1)
                        .allowsTightening(true)
                }
            }
        }
    }
}
