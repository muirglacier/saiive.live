//
//  FormattableView.swift
//  watch Extension
//
//  Created by Dominik Pfaffenbauer on 16.09.21.
//

import SwiftUI

struct Formattable {
    static func formatNumber( number: Double, style: NumberFormatter.Style = .currency, fraction: Int = 8) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = style
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = fraction;
        formatter.maximumFractionDigits = fraction;

        return formatter.string(from: NSNumber(value: number)) ?? "$0"
    }
}
