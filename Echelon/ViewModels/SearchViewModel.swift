//
//  SearchViewModel.swift
//  Echelon
//
//  Owns the state for the game search screen: the current query, the
//  results, the loading flag, and any error message. Debounces typing
//  and cancels stale searches so we don't hammer RAWG or race results.
//

import Foundation

@MainActor
@Observable
final class SearchViewModel {

    // MARK: - State

    /// Bound to the search TextField. didSet triggers debounced search.
    var searchQuery: String = "" {
        didSet {
            guard searchQuery != oldValue else { return }
            scheduleSearch()
        }
    }

    /// Read-only from outside the VM — only this class mutates results.
    private(set) var results: [Game] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?

    // MARK: - Private internals

    /// The currently-pending or in-flight search. Cancelled on every keystroke.
    private var searchTask: Task<Void, Never>?

    /// How long to wait after the last keystroke before actually searching.
    private let debounceDuration: Duration = .milliseconds(300)

    // MARK: - Search logic

    private func scheduleSearch() {
        // 1. Cancel anything currently pending. The user is still typing.
        searchTask?.cancel()

        // 2. Don't hit the API for empty input — clear and bail.
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            results = []
            isLoading = false
            errorMessage = nil
            return
        }

        // 3. Schedule a new search. The debounce sleep is itself cancellable.
        searchTask = Task { [weak self, debounceDuration] in
            try? await Task.sleep(for: debounceDuration)
            guard !Task.isCancelled else { return }
            await self?.performSearch(for: trimmed)
        }
    }

    private func performSearch(for query: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let games = try await RAWGService.searchGames(query: query)
            // If we were cancelled while the network call was in flight,
            // a newer search is on its way — don't clobber its state.
            guard !Task.isCancelled else { return }
            results = games
            isLoading = false
        } catch {
            guard !Task.isCancelled else { return }
            results = []
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}
