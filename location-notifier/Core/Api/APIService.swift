//
//  APIService.swift
//  location-notifier
//
//  Created by Max on 2026-01-31.
//

private let backendURLString = "https://localhost:8000/api"

import Foundation

class APIService {
    /// Performs a request to the backend using async/await and returns the response data.
    /// - Parameter body: HTTP Body
    /// - Parameter method: The HTTP method to use (e.g., "GET", "POST").
    /// - Throws: An error if the URL is invalid, the request fails, or the response status code is not 2xx.
    /// - Returns: The response body as `Data`.
    func callBackendAPI(body: Data, method: String) async throws -> Data {
        guard let url = URL(string: backendURLString) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]
        request.httpBody = body
        request.httpMethod = method
        

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return data
    }
}
