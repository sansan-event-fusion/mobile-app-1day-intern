//
//  APIClient.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/08.
//

import Foundation

protocol APIRequestHeader {
    var headers: [String: String] { get }
}

protocol APIRequestQueryParameter {
    var parameters: [String: String] { get }
}

protocol APIRequestBodyParameter {
    var bodyParameters: [String: Any] { get }
}

protocol APIRequest {
    associatedtype Response: Decodable
    var baseURL: URL { get }
    var path: String { get }
    var method: String { get }
    var header: APIRequestHeader { get }
    var queryParameters: APIRequestQueryParameter { get }
    var bodyParameters: APIRequestBodyParameter { get }
}

protocol APIClientInterface {
    func send<Request: APIRequest>(_ request: Request) async throws -> Request.Response
}

enum APIError: Error {
    case invalidResponse
    case failureRequest(statusCode: Int)
    
    var localizedDescription: String {
        switch self {
        case .invalidResponse:
            return String(localized: "api_error_invalid_response")
        case .failureRequest(let statusCode):
            return String(localized: "api_error_failure_request") + ": \(statusCode)"
        }
    }
}

final class APIClient: APIClientInterface {
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func send<Request: APIRequest>(_ request: Request) async throws -> Request.Response {
        let url = request.baseURL.appendingPathComponent(request.path)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = request.queryParameters.parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        var urlRequest = URLRequest(url: urlComponents.url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        urlRequest.httpMethod = request.method
        urlRequest.allHTTPHeaderFields = request.header.headers
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: request.bodyParameters.bodyParameters, options: [])

        NSLog("Sned Request: \(urlRequest), \(request.bodyParameters.bodyParameters)")
        let (data, response) = try await urlSession.data(for: urlRequest)
        NSLog("Response: \(response)")
        guard let httpResponse = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard httpResponse.statusCode == 200 else {
            throw APIError.failureRequest(statusCode: httpResponse.statusCode)
        }

        let jsonResponse = try JSONDecoder().decode(Request.Response.self, from: data)
        NSLog("Json Response: \(jsonResponse)")
        return jsonResponse
    }
}
