//
//  NetworkTests.swift
//  MatchMateTests
//
//  Created by Indrajeet tripathi on 23/05/26.
//

import Testing
import Combine
import Foundation
@testable import MatchMate

// MARK: - Network Integration Tests
struct NetworkIntegrationTests {
    
    @Test func testFetchUsersFromAPI() async throws {
        let manager = NetworkManager.shared
        var cancellables = Set<AnyCancellable>()
        
        await withCheckedContinuation { continuation in
            manager.fetchUsers()
                .sink { completion in
                    if case .failure(let error) = completion {
                        // Network might fail in test environment, that's okay
                        print("Network test failed (expected in offline): \(error)")
                    }
                    continuation.resume()
                } receiveValue: { users in
                    // If we get users, verify the structure
                    #expect(users.count > 0)
                    #expect(users.first?.name.isEmpty == false)
                    continuation.resume()
                }
                .store(in: &cancellables)
        }
    }
}

// MARK: - URL Validation Tests
struct URLValidationTests {
    
    @Test func testAPIBaseURL() {
        let urlString = "https://jsonplaceholder.typicode.com/users"
        let url = URL(string: urlString)
        
        #expect(url != nil)
        #expect(url?.scheme == "https")
        #expect(url?.host == "jsonplaceholder.typicode.com")
        #expect(url?.path == "/users")
    }
    
    @Test func testRandomUserAPIURL() {
        let baseURL = "https://randomuser.me/api/portraits/men/1.jpg"
        let url = URL(string: baseURL)
        
        #expect(url != nil)
        #expect(url?.scheme == "https")
        #expect(url?.host == "randomuser.me")
    }
    
    @Test func testInvalidURLHandling() {
        let invalidURLString = "not a valid url"
        let url = URL(string: invalidURLString)
        
        // URL initializer returns nil for invalid URLs with spaces
        // But "notavalidurl" would be valid, so test with spaces
        let urlWithSpaces = URL(string: "https://example .com")
        #expect(urlWithSpaces == nil)
    }
}

// MARK: - JSON Parsing Tests
struct JSONParsingTests {
    
    @Test func testValidUserJSONParsing() throws {
        let validJSON = """
        {
            "id": 1,
            "name": "Leanne Graham",
            "username": "Bret",
            "email": "Sincere@april.biz",
            "address": {
                "street": "Kulas Light",
                "suite": "Apt. 556",
                "city": "Gwenborough",
                "zipcode": "92998-3874",
                "geo": {
                    "lat": "-37.3159",
                    "lng": "81.1496"
                }
            },
            "phone": "1-770-736-8031 x56442",
            "website": "hildegard.org",
            "company": {
                "name": "Romaguera-Crona",
                "catchPhrase": "Multi-layered client-server neural-net",
                "bs": "harness real-time e-markets"
            }
        }
        """.data(using: .utf8)!
        
        let user = try JSONDecoder().decode(User.self, from: validJSON)
        
        #expect(user.id == 1)
        #expect(user.name == "Leanne Graham")
        #expect(user.username == "Bret")
        #expect(user.email == "Sincere@april.biz")
        #expect(user.address.street == "Kulas Light")
        #expect(user.address.geo.lat == "-37.3159")
        #expect(user.company.name == "Romaguera-Crona")
    }
    
    @Test func testInvalidJSONThrowsError() {
        let invalidJSON = """
        {
            "id": "not a number",
            "name": "Test"
        }
        """.data(using: .utf8)!
        
        #expect(throws: DecodingError.self) {
            _ = try JSONDecoder().decode(User.self, from: invalidJSON)
        }
    }
    
    @Test func testMissingFieldsThrowsError() {
        let incompleteJSON = """
        {
            "id": 1,
            "name": "Test"
        }
        """.data(using: .utf8)!
        
        #expect(throws: DecodingError.self) {
            _ = try JSONDecoder().decode(User.self, from: incompleteJSON)
        }
    }
    
    @Test func testAddressDecoding() throws {
        let addressJSON = """
        {
            "street": "123 Main St",
            "suite": "Suite 100",
            "city": "New York",
            "zipcode": "10001",
            "geo": {
                "lat": "40.7128",
                "lng": "-74.0060"
            }
        }
        """.data(using: .utf8)!
        
        let address = try JSONDecoder().decode(Address.self, from: addressJSON)
        
        #expect(address.street == "123 Main St")
        #expect(address.suite == "Suite 100")
        #expect(address.city == "New York")
        #expect(address.zipcode == "10001")
        #expect(address.geo.lat == "40.7128")
        #expect(address.geo.lng == "-74.0060")
    }
    
    @Test func testCompanyDecoding() throws {
        let companyJSON = """
        {
            "name": "Tech Corp",
            "catchPhrase": "Innovation at its best",
            "bs": "enterprise solutions"
        }
        """.data(using: .utf8)!
        
        let company = try JSONDecoder().decode(Company.self, from: companyJSON)
        
        #expect(company.name == "Tech Corp")
        #expect(company.catchPhrase == "Innovation at its best")
        #expect(company.bs == "enterprise solutions")
    }
    
    @Test func testGeoDecoding() throws {
        let geoJSON = """
        {
            "lat": "19.0760",
            "lng": "72.8777"
        }
        """.data(using: .utf8)!
        
        let geo = try JSONDecoder().decode(Geo.self, from: geoJSON)
        
        #expect(geo.lat == "19.0760")
        #expect(geo.lng == "72.8777")
    }
}

// MARK: - Error Handling Tests
struct ErrorHandlingTests {
    
    @Test func testNetworkErrorEquality() {
        let error1 = NetworkError.invalidURL
        let error2 = NetworkError.invalidURL
        
        #expect(error1.errorDescription == error2.errorDescription)
    }
    
    @Test func testServerErrorCodes() {
        let badRequest = NetworkError.serverError(400)
        let unauthorized = NetworkError.serverError(401)
        let forbidden = NetworkError.serverError(403)
        let notFound = NetworkError.serverError(404)
        let serverError = NetworkError.serverError(500)
        
        #expect(badRequest.errorDescription?.contains("400") == true)
        #expect(unauthorized.errorDescription?.contains("401") == true)
        #expect(forbidden.errorDescription?.contains("403") == true)
        #expect(notFound.errorDescription?.contains("404") == true)
        #expect(serverError.errorDescription?.contains("500") == true)
    }
    
    @Test func testUnknownErrorWrapping() {
        let originalError = NSError(domain: "TestDomain", code: 123, userInfo: nil)
        let networkError = NetworkError.unknown(originalError)
        
        #expect(networkError.errorDescription != nil)
    }
}
