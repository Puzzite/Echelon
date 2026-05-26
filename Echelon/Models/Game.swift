//
//  Game.swift
//  Echelon
//
//  Domain model for a game returned by the RAWG API.
//  Decoded directly from the JSON in /api/games search results.
//

import Foundation

struct Game: Identifiable, Hashable, Decodable {
    let id: Int
    let slug: String
    let name: String
    let released: String?
    let backgroundImage: URL?
    let rating: Double?
    let metacritic: Int?
}
