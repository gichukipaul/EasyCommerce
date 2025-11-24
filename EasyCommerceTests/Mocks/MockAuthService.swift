//
//  MockAuthService.swift
//  EasyCommerceTests
//
//  Created for testing purposes
//

import Foundation
@testable import EasyCommerce

final class MockAuthService: AuthService {

    // MARK: - Control Properties
    var shouldThrowError = false
    var errorToThrow: Error = EasyCommerceError.INVALID_URL

    // MARK: - Stub Data
    var stubbedLoginResponse: LogInResponse?

    // MARK: - Call Tracking
    var loginCalled = false
    var lastUsername: String?
    var lastPassword: String?

    // MARK: - AuthService Implementation

    func login(with username: String, pwd: String) async throws -> LogInResponse {
        loginCalled = true
        lastUsername = username
        lastPassword = pwd

        if shouldThrowError {
            throw errorToThrow
        }

        guard let response = stubbedLoginResponse else {
            throw EasyCommerceError.INVALID_URL
        }

        return response
    }

    // MARK: - Helper Methods

    func reset() {
        shouldThrowError = false
        errorToThrow = EasyCommerceError.INVALID_URL
        stubbedLoginResponse = nil
        loginCalled = false
        lastUsername = nil
        lastPassword = nil
    }
}
