//
//  RAWGService.swift
//  Echelon
//
//  Thin wrapper around the RAWG /api/games search endpoint.
//  Builds the URL with URLComponents, hits the network with
//  URLSession + async/await, and decodes the response into [Game].
//

import Foundation

enum RAWGService {

    // MARK: - Errors

    /// Failure modes the caller may want to surface to the UI.
    /// Kept as a small enum so a view model can switch on the cause
    /// and pick the right message — no error strings hardcoded in views.
    enum RAWGError: Error, LocalizedError {
        case missingAPIKey
        case invalidURL
        case requestFailed(statusCode: Int)
        case decodingFailed
        case transport(Error)

        var errorDescription: String? {
            switch self {
            case .missingAPIKey:
                return "RAWG API key is missing. Add it in Config/APIKeys.swift."
            case .invalidURL:
                return "Could not build the search URL."
            case .requestFailed(let code):
                return "RAWG request failed (status \(code))."
            case .decodingFailed:
                return "Could not read the response from RAWG."
            case .transport(let error):
                return "Network error: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Response shape

    /// RAWG wraps results in `{ "count": ..., "results": [...] }`.
    /// We only care about `results` for now, so the wrapper stays
    /// private — callers receive `[Game]` directly.
    private struct SearchResponse: Decodable {
        let results: [Game]
    }

    // MARK: - Endpoints

    /// Searches RAWG for games matching `query`.
    /// Returns up to 20 results. No pagination yet.
    static func searchGames(query: String) async throws -> [Game] {
        guard !APIKeys.rawg.isEmpty else {
            throw RAWGError.missingAPIKey
        }

        var components = URLComponents(string: "https://api.rawg.io/api/games")
        components?.queryItems = [
            URLQueryItem(name: "key", value: APIKeys.rawg),
            URLQueryItem(name: "search", value: query),
            URLQueryItem(name: "page_size", value: "20")
        ]

        guard let url = components?.url else {
            throw RAWGError.invalidURL
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw RAWGError.transport(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw RAWGError.requestFailed(statusCode: -1)
        }
        guard (200..<300).contains(http.statusCode) else {
            throw RAWGError.requestFailed(statusCode: http.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            let decoded = try decoder.decode(SearchResponse.self, from: data)
            return decoded.results
        } catch {
            throw RAWGError.decodingFailed
        }
    }
}
