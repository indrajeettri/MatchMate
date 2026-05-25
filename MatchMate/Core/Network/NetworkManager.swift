//
//  NetworkManager.swift
//  MatchMate
//
//  Created by Indrajeet tripathi on 23/05/26.
//

import Foundation
import Combine

// MARK: - Network Error
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case noInternet
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let code):
            return "Server error: \(code)"
        case .noInternet:
            return "No internet connection"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - API Endpoint
enum APIEndpoint {
    case users
    
    var url: URL? {
        switch self {
        case .users:
            return URL(string: "https://jsonplaceholder.typicode.com/users")
        }
    }
}

// MARK: - Network Manager (Conforms to NetworkServiceProtocol)
final class NetworkManager: NetworkServiceProtocol {
    
    // MARK: - Singleton
    static let shared: NetworkServiceProtocol = NetworkManager()
    
    // MARK: - Properties
    private let session: URLSession
    
    // MARK: - Initialization
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - NetworkServiceProtocol Implementation
    
    func fetchUsers() -> AnyPublisher<[User], NetworkError> {
        guard let url = APIEndpoint.users.url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .mapError { error -> NetworkError in
                if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                    return .noInternet
                }
                return .unknown(error)
            }
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.noData
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.serverError(httpResponse.statusCode)
                }
                
                return data
            }
            .handleEvents(receiveOutput: { data in
                // Print JSON response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 [API Response] JSON:")
                    print(jsonString)
                }
            })
            .decode(type: [User].self, decoder: JSONDecoder())
            .mapError { error -> NetworkError in
                if error is DecodingError {
                    return .decodingError
                }
                return error as? NetworkError ?? .unknown(error)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func syncMatchStatus(profileId: Int64, status: MatchStatus) -> AnyPublisher<Bool, NetworkError> {
        // Simulating API call for syncing status
        // In real app, this would be an actual API endpoint
        return Future<Bool, NetworkError> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                // Simulate successful sync
                promise(.success(true))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
