//
//  UserManager.swift
//  EasyCommerce
//
//  Persistent user data management
//

import Foundation
import SwiftUI

// MARK: - User Model

struct User: Codable, Equatable {
    let id: String
    var email: String
    var firstName: String
    var lastName: String
    var avatarURL: String?
    var createdAt: Date

    var fullName: String {
        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }

    var initials: String {
        let first = firstName.first.map { String($0) } ?? ""
        let last = lastName.first.map { String($0) } ?? ""
        return "\(first)\(last)".uppercased()
    }
}

// MARK: - Auth State

enum AuthState: Equatable {
    case unknown
    case unauthenticated
    case authenticated(User)

    var isAuthenticated: Bool {
        if case .authenticated = self { return true }
        return false
    }

    var user: User? {
        if case .authenticated(let user) = self { return user }
        return nil
    }
}

// MARK: - User Manager

@MainActor
final class UserManager: ObservableObject {
    static let shared = UserManager()

    @Published private(set) var authState: AuthState = .unknown
    @Published private(set) var isLoading: Bool = false
    @Published var error: String?
    @Published var hasCompletedOnboarding: Bool = false

    // Keys for UserDefaults
    private let userKey = "currentUser"
    private let tokenKey = "authToken"
    private let onboardingKey = "hasCompletedOnboarding"

    private let authManager: AuthService

    private init(authManager: AuthService = AuthManager.shared) {
        self.authManager = authManager
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
        loadPersistedUser()
    }

    // MARK: - Computed Properties

    var currentUser: User? {
        authState.user
    }

    var isAuthenticated: Bool {
        authState.isAuthenticated
    }

    // MARK: - Authentication

    func signIn(email: String, password: String) async {
        isLoading = true
        error = nil

        do {
            // Use the existing auth manager
            let response = try await authManager.login(with: email, pwd: password)

            // Create user from response (in real app, decode from token or fetch profile)
            let user = User(
                id: UUID().uuidString,
                email: email,
                firstName: email.components(separatedBy: "@").first ?? "User",
                lastName: "",
                createdAt: Date()
            )

            // Persist
            persistUser(user)
            persistToken(response.token)

            withAnimation(AppTheme.Animation.standard) {
                authState = .authenticated(user)
            }
        } catch {
            self.error = "Invalid email or password. Please try again."
            authState = .unauthenticated
        }

        isLoading = false
    }

    func signUp(email: String, password: String, firstName: String, lastName: String) async {
        isLoading = true
        error = nil

        // Simulate API call (FakeStore API doesn't have real signup)
        try? await Task.sleep(nanoseconds: 1_500_000_000)

        let user = User(
            id: UUID().uuidString,
            email: email,
            firstName: firstName,
            lastName: lastName,
            createdAt: Date()
        )

        // Persist
        persistUser(user)
        persistToken("fake-token-\(UUID().uuidString)")

        withAnimation(AppTheme.Animation.standard) {
            authState = .authenticated(user)
        }

        isLoading = false
    }

    func signOut() {
        withAnimation(AppTheme.Animation.standard) {
            authState = .unauthenticated
        }
        clearPersistedData()
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }

    // MARK: - Persistence

    private func loadPersistedUser() {
        if let data = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            authState = .authenticated(user)
        } else {
            authState = .unauthenticated
        }
    }

    private func persistUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
    }

    private func persistToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }

    private func clearPersistedData() {
        UserDefaults.standard.removeObject(forKey: userKey)
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
}
