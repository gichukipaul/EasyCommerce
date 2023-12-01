//
//  AuthViewModel.swift
//  EasyCommerce
//
//  Created by Gichuki on 01/12/2023.
//

import Foundation

@MainActor
class AuthViewModel: ObservableObject {
    
    let authManager: AuthService
    
    @Published private(set) var token : String?
    
    init(authManager : AuthService) {
        self.authManager = authManager
    }
    
    func login(username: String, password : String) async {
        do {
            let tokenData = try await authManager.login(with: username, pwd: password)
            self.token =  tokenData.token
        } catch {
            print("AuthVM: ERROR")
        }
    }
    
}
