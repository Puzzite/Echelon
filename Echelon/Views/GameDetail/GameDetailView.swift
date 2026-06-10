//
//  GameDetailView.swift
//  Echelon
//
//  Detail page for a single game, built entirely from the Game we
//  already have from search results. Purely presentational — no
//  ViewModel, no extra API call. The status buttons are placeholders
//  until tracking/persistence exists.
//

import SwiftUI

struct GameDetailView: View {
    let game: Game

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                heroImage

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(game.name)
                            .font(.largeTitle.bold())

                        if let released = formattedReleaseDate {
                            Text("Released \(released)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    ratingsRow

                    statusButtons
                }
                .padding([.horizontal, .bottom])
            }
        }
        .navigationTitle(game.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Hero image

    private var heroImage: some View {
        // Color.clear defines the layout (full width × 220). The image
        // lives in an overlay, so however large .fill scales it, it can
        // never push the surrounding VStack wider than the screen.
        Color.clear
            .frame(height: 220)
            .overlay {
                AsyncImage(url: game.backgroundImage) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .empty:
                        ProgressView()
                    case .failure:
                        placeholderArt
                    @unknown default:
                        placeholderArt
                    }
                }
            }
            .clipped()
    }

    private var placeholderArt: some View {
        Image(systemName: "gamecontroller")
            .font(.largeTitle)
            .foregroundStyle(.secondary)
    }

    // MARK: - Ratings

    @ViewBuilder
    private var ratingsRow: some View {
        if game.rating != nil || game.metacritic != nil {
            HStack(spacing: 36) {
                if let rating = game.rating {
                    VStack(spacing: 2) {
                        Text(rating, format: .number.precision(.fractionLength(1)))
                            .font(.title3.bold())
                        Text("RAWG")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if let metacritic = game.metacritic {
                    VStack(spacing: 2) {
                        Text("\(metacritic)")
                            .font(.title3.bold())
                        Text("Metacritic")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    private var formattedReleaseDate: String? {
        guard let released = game.released else { return nil }
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = inputFormatter.date(from: released) else { return released }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d, yyyy"
        
        return outputFormatter.string(from: date)
        
    }

    // MARK: - Status actions (placeholders)

    private var statusButtons: some View {
        VStack(spacing: 12) {
            Button {
                // TODO: wire up once tracking/persistence exists
            } label: {
                Label("Add to Backlog", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button {
                // TODO: wire up once tracking/persistence exists
            } label: {
                Label("Mark as Played", systemImage: "checkmark")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview {
    NavigationStack {
        GameDetailView(
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
    }
}
