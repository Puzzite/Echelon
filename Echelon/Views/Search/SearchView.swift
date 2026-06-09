//
//  SearchView.swift
//  Echelon
//
//  The game search screen. Owns a SearchViewModel, renders the
//  current state (idle / loading / error / empty / results), and
//  lets the user tap a result to navigate to its detail page.
//

import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Search")
                .navigationDestination(for: Game.self) { game in
                    // Placeholder destination — GameDetailView replaces
                    // this in the next step.
                    Text(game.name)
                        .navigationTitle(game.name)
                }
        }
        .searchable(text: $viewModel.searchQuery, prompt: "Search for a game")
    }

    // MARK: - State-driven content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Searching…")
        } else if let error = viewModel.errorMessage {
            ContentUnavailableView(
                "Something went wrong",
                systemImage: "exclamationmark.triangle",
                description: Text(error)
            )
        } else if viewModel.results.isEmpty {
            if viewModel.searchQuery.isEmpty {
                ContentUnavailableView(
                    "Find your next game",
                    systemImage: "magnifyingglass",
                    description: Text("Search for games to track, rate, and review.")
                )
            } else {
                ContentUnavailableView.search(text: viewModel.searchQuery)
            }
        } else {
            List(viewModel.results) { game in
                NavigationLink(value: game) {
                    GameRowView(game: game)
                }
            }
            .listStyle(.plain)
        }
    }
}

#Preview {
    SearchView()
}
