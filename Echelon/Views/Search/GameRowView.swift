//
//  GameRowView.swift
//  Echelon
//
//  A single row in the search results list: cover art, title,
//  release year, and Metacritic badge. Pure presentation — it
//  takes a Game and draws it, holds no state of its own.
//

import SwiftUI

struct GameRowView: View {
    let game: Game

    var body: some View {
        HStack(spacing: 12) {
            cover

            VStack(alignment: .leading, spacing: 4) {
                Text(game.name)
                    .font(.headline)
                    .lineLimit(2)

                if let year = releaseYear {
                    Text(year)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if let metacritic = game.metacritic {
                Text("\(metacritic)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(metacriticColor(metacritic))
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Subviews

    private var cover: some View {
        AsyncImage(url: game.backgroundImage) { phase in
            switch phase {
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fill)
            case .empty:
                ProgressView()
            case .failure:
                placeholderArt
            @unknown default:
                placeholderArt
            }
        }
        .frame(width: 64, height: 64)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var placeholderArt: some View {
        Image(systemName: "gamecontroller")
            .foregroundStyle(.secondary)
    }

    // MARK: - Derived display values

    /// RAWG returns dates as "YYYY-MM-DD". We only show the year.
    private var releaseYear: String? {
        guard let released = game.released, released.count >= 4 else { return nil }
        return String(released.prefix(4))
    }

    private func metacriticColor(_ score: Int) -> Color {
        switch score {
        case 75...: return .green
        case 50..<75: return .yellow
        default: return .red
        }
    }
}

#Preview {
    GameRowView(
        game: Game(
            id: 1,
            slug: "halo-infinite",
            name: "Halo Infinite",
            released: "2021-12-08",
            backgroundImage: nil,
            rating: 4.2,
            metacritic: 87
        )
    )
    .padding()
}
