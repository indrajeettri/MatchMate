//
//  MatchMateTests.swift
//  MatchMateTests
//
//  Created by Indrajeet tripathi  on 23/05/26.
//

import Testing
import Foundation
@testable import MatchMate

// MARK: - User Model Tests
struct UserModelTests {
    
    @Test func testUserDecoding() throws {
        let json = """
        {
            "id": 1,
            "name": "John Doe",
            "username": "johndoe",
            "email": "john@example.com",
            "address": {
                "street": "123 Main St",
                "suite": "Apt 1",
                "city": "Mumbai",
                "zipcode": "400001",
                "geo": {
                    "lat": "19.0760",
                    "lng": "72.8777"
                }
            },
            "phone": "+91 9876543210",
            "website": "johndoe.com",
            "company": {
                "name": "Tech Corp",
                "catchPhrase": "Innovation first",
                "bs": "technology solutions"
            }
        }
        """.data(using: .utf8)!
        
        let user = try JSONDecoder().decode(User.self, from: json)
        
        #expect(user.id == 1)
        #expect(user.name == "John Doe")
        #expect(user.email == "john@example.com")
        #expect(user.address.city == "Mumbai")
        #expect(user.company.name == "Tech Corp")
    }
    
    @Test func testUserArrayDecoding() throws {
        let json = """
        [
            {
                "id": 1,
                "name": "User One",
                "username": "user1",
                "email": "user1@test.com",
                "address": {"street": "St 1", "suite": "A", "city": "City1", "zipcode": "111", "geo": {"lat": "0", "lng": "0"}},
                "phone": "111",
                "website": "user1.com",
                "company": {"name": "Company1", "catchPhrase": "CP1", "bs": "BS1"}
            },
            {
                "id": 2,
                "name": "User Two",
                "username": "user2",
                "email": "user2@test.com",
                "address": {"street": "St 2", "suite": "B", "city": "City2", "zipcode": "222", "geo": {"lat": "0", "lng": "0"}},
                "phone": "222",
                "website": "user2.com",
                "company": {"name": "Company2", "catchPhrase": "CP2", "bs": "BS2"}
            }
        ]
        """.data(using: .utf8)!
        
        let users = try JSONDecoder().decode([User].self, from: json)
        
        #expect(users.count == 2)
        #expect(users[0].name == "User One")
        #expect(users[1].name == "User Two")
    }
}

// MARK: - MatchStatus Tests
struct MatchStatusTests {
    
    @Test func testMatchStatusRawValues() {
        #expect(MatchStatus.pending.rawValue == "pending")
        #expect(MatchStatus.accepted.rawValue == "accepted")
        #expect(MatchStatus.declined.rawValue == "declined")
    }
    
    @Test func testMatchStatusDisplayText() {
        #expect(MatchStatus.pending.displayText == "Pending")
        #expect(MatchStatus.accepted.displayText == "Member Accepted")
        #expect(MatchStatus.declined.displayText == "Member Declined")
    }
    
    @Test func testMatchStatusFromRawValue() {
        #expect(MatchStatus(rawValue: "pending") == .pending)
        #expect(MatchStatus(rawValue: "accepted") == .accepted)
        #expect(MatchStatus(rawValue: "declined") == .declined)
        #expect(MatchStatus(rawValue: "invalid") == nil)
    }
    
    @Test func testMatchStatusAllCases() {
        let allCases = MatchStatus.allCases
        #expect(allCases.count == 3)
        #expect(allCases.contains(.pending))
        #expect(allCases.contains(.accepted))
        #expect(allCases.contains(.declined))
    }
}

// MARK: - ProfileViewModel Tests
struct ProfileViewModelTests {
    
    @Test func testProfileViewModelInitialization() {
        let profile = ProfileViewModel(
            id: 1,
            name: "Test User",
            email: "test@example.com",
            phone: "+91 1234567890",
            website: "test.com",
            company: "Test Company",
            city: "Mumbai",
            address: "123 Test St",
            imageURL: "https://example.com/image.jpg",
            matchStatus: .pending,
            syncPending: false
        )
        
        #expect(profile.id == 1)
        #expect(profile.name == "Test User")
        #expect(profile.email == "test@example.com")
        #expect(profile.matchStatus == .pending)
        #expect(profile.syncPending == false)
    }
    
    @Test func testProfileViewModelIdentifiable() {
        let profile = ProfileViewModel(
            id: 42,
            name: "Test",
            email: "",
            phone: "",
            website: "",
            company: "",
            city: "",
            address: "",
            imageURL: "",
            matchStatus: .pending,
            syncPending: false
        )
        
        #expect(profile.id == 42)
    }
    
    @Test func testProfileViewModelMutability() {
        var profile = ProfileViewModel(
            id: 1,
            name: "Test",
            email: "",
            phone: "",
            website: "",
            company: "",
            city: "",
            address: "",
            imageURL: "",
            matchStatus: .pending,
            syncPending: false
        )
        
        profile.matchStatus = .accepted
        profile.syncPending = true
        
        #expect(profile.matchStatus == .accepted)
        #expect(profile.syncPending == true)
    }
}

// MARK: - NetworkError Tests
struct NetworkErrorTests {
    
    @Test func testNetworkErrorDescriptions() {
        #expect(NetworkError.invalidURL.errorDescription == "Invalid URL")
        #expect(NetworkError.noData.errorDescription == "No data received")
        #expect(NetworkError.decodingError.errorDescription == "Failed to decode response")
        #expect(NetworkError.serverError(500).errorDescription == "Server error: 500")
        #expect(NetworkError.noInternet.errorDescription == "No internet connection")
    }
    
    @Test func testServerErrorWithDifferentCodes() {
        #expect(NetworkError.serverError(400).errorDescription == "Server error: 400")
        #expect(NetworkError.serverError(401).errorDescription == "Server error: 401")
        #expect(NetworkError.serverError(403).errorDescription == "Server error: 403")
        #expect(NetworkError.serverError(404).errorDescription == "Server error: 404")
        #expect(NetworkError.serverError(500).errorDescription == "Server error: 500")
    }
}

// MARK: - API Endpoint Tests
struct APIEndpointTests {
    
    @Test func testUsersEndpointURL() {
        let endpoint = APIEndpoint.users
        #expect(endpoint.url?.absoluteString == "https://jsonplaceholder.typicode.com/users")
    }
    
    @Test func testUsersEndpointURLNotNil() {
        let endpoint = APIEndpoint.users
        #expect(endpoint.url != nil)
    }
}
