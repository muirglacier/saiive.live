//
//  IconPairView.swift
//  watch Extension
//
//  Created by Dominik Pfaffenbauer on 16.09.21.
//

import SwiftUI

struct IconPairView: View {
    var tokenA: String
    var tokenB: String
    
    var body: some View {
        ZStack {
            IconView(token: tokenA)
            IconView(token: tokenB).offset(x: 30).padding(.trailing, 30)
        }
    }
}
