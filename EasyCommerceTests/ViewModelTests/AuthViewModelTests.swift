//
//  AuthViewModelTests.swift
//  EasyCommerceTests
//
//  Unit tests for AuthViewModel
//

import XCTest
@testable import EasyCommerce

@MainActor
final class AuthViewModelTests: XCTestCase {

    var sut: AuthViewModel!
    var mockAuthService: MockAuthService!

    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        sut = AuthViewModel(authManager: mockAuthService)
    }

    override func tearDown() {
        sut = nil
        mockAuthService = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState_TokenIsNil() {
        XCTAssertNil(sut.token)
    }

    // MARK: - Login Tests

    func testLogin_CallsAuthService() async {
        // Given
        let username = "testuser"
        let password = "testpass"
        mockAuthService.stubbedLoginResponse = TestData.sampleLoginResponse

        // When
        await sut.login(username: username, password: password)

        // Then
        XCTAssertTrue(mockAuthService.loginCalled)
    }

    func testLogin_PassesCorrectCredentials() async {
        // Given
        let username = "testuser"
        let password = "testpass"
        mockAuthService.stubbedLoginResponse = TestData.sampleLoginResponse

        // When
        await sut.login(username: username, password: password)

        // Then
        XCTAssertEqual(mockAuthService.lastUsername, username)
        XCTAssertEqual(mockAuthService.lastPassword, password)
    }

    func testLogin_SetsTokenOnSuccess() async {
        // Given
        let expectedToken = "test-jwt-token-12345"
        mockAuthService.stubbedLoginResponse = LogInResponse(token: expectedToken)

        // When
        await sut.login(username: "user", password: "pass")

        // Then
        XCTAssertEqual(sut.token, expectedToken)
    }

    func testLogin_TokenRemainsNilOnError() async {
        // Given
        mockAuthService.shouldThrowError = true
        mockAuthService.errorToThrow = EasyCommerceError.INVALID_URL

        // When
        await sut.login(username: "user", password: "pass")

        // Then
        XCTAssertNil(sut.token)
    }

    func testLogin_HandlesEmptyCredentials() async {
        // Given
        mockAuthService.stubbedLoginResponse = TestData.sampleLoginResponse

        // When
        await sut.login(username: "", password: "")

        // Then
        XCTAssertTrue(mockAuthService.loginCalled)
        XCTAssertEqual(mockAuthService.lastUsername, "")
        XCTAssertEqual(mockAuthService.lastPassword, "")
    }

    func testLogin_HandlesSpecialCharactersInCredentials() async {
        // Given
        let username = "user@email.com"
        let password = "p@ss!w0rd#123"
        mockAuthService.stubbedLoginResponse = TestData.sampleLoginResponse

        // When
        await sut.login(username: username, password: password)

        // Then
        XCTAssertEqual(mockAuthService.lastUsername, username)
        XCTAssertEqual(mockAuthService.lastPassword, password)
    }

    // MARK: - Multiple Login Attempts Tests

    func testMultipleLogins_UpdatesTokenWithLatest() async {
        // Given
        let firstToken = "first-token"
        let secondToken = "second-token"

        // When - first login
        mockAuthService.stubbedLoginResponse = LogInResponse(token: firstToken)
        await sut.login(username: "user1", password: "pass1")
        XCTAssertEqual(sut.token, firstToken)

        // When - second login
        mockAuthService.stubbedLoginResponse = LogInResponse(token: secondToken)
        await sut.login(username: "user2", password: "pass2")

        // Then
        XCTAssertEqual(sut.token, secondToken)
    }

    func testLoginAfterFailure_CanSucceed() async {
        // Given - first login fails
        mockAuthService.shouldThrowError = true
        await sut.login(username: "user", password: "pass")
        XCTAssertNil(sut.token)

        // When - second login succeeds
        mockAuthService.shouldThrowError = false
        mockAuthService.stubbedLoginResponse = TestData.sampleLoginResponse
        await sut.login(username: "user", password: "pass")

        // Then
        XCTAssertNotNil(sut.token)
    }

    // MARK: - Edge Cases

    func testLogin_WithLongToken() async {
        // Given
        let longToken = String(repeating: "a", count: 1000)
        mockAuthService.stubbedLoginResponse = LogInResponse(token: longToken)

        // When
        await sut.login(username: "user", password: "pass")

        // Then
        XCTAssertEqual(sut.token, longToken)
        XCTAssertEqual(sut.token?.count, 1000)
    }
}
