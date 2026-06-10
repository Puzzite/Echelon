//
//  MetacriticStyle.swift
//  Echelon
//
// Helper enum for determining the color
// of a metacritic score
//

import SwiftUI

enum MetacriticStyle {
    static func color(for score: Int) -> Color {
        switch score {
        case 75...:
            return .green
        case 50..<75:
            return .yellow
        default:
            return .red
        }
    }
}
