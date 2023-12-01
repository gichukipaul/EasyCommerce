//
//  AuthService.swift
//  EasyCommerce
//
//  Created by Gichuki on 01/12/2023.
//

import Foundation

protocol AuthService {
        // LOGIN
    func login(with username: String, pwd: String) async throws -> LogInResponse
}

final class AuthManager : AuthService{
    static let shared = AuthManager()
    private init() { }
    
    func login(with username: String, pwd: String) async throws -> LogInResponse {
        guard let url = URL(string: Constants.Urls.AUTH_URL) else {
            print("LOGIN: invalid url")
            throw EasyCommerceError.INVALID_URL
        }
        
        var request = URLRequest(url: url)
        let loginRequest = LogInRequest(username: username, password: pwd)
        let requestBody =  try JSONEncoder().encode(loginRequest)
        
        request.httpBody = requestBody
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, !(200...299 ~= response.statusCode) else {
            print("LOGIN: NO DATA FROM SERVER")
            throw EasyCommerceError.INVALID_URL
        }
        
        let decodedData = try JSONDecoder().decode(LogInResponse.self, from: data)
        
        return decodedData
    }
}
