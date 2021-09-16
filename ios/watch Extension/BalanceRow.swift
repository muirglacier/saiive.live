//
//  BalanceRow.swift
//  watch Extension
//
//  Created by Dominik Pfaffenbauer on 16.09.21.
//

import SwiftUI

struct BalanceRow: View {
    var balance: Balance
    
    var body: some View {
        HStack {
            IconView(token: balance.token)

            VStack(alignment: .leading) {
                Text(balance.tokenDisplay).font(.headline)
                Text("\(balance.balanceDisplay)")
                    .lineLimit(1)
                    .allowsTightening(true)
            }
        }
    }
}
