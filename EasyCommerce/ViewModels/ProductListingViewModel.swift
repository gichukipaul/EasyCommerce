//
//  ProductListingViewModel.swift
//  EasyCommerce
//
//  Created by Gichuki on 12/11/2023.
//

import Foundation

class ProductListingViewModel: ObservableObject {
    let networkManager: NetworkService
    
    @Published var products: [Product] = []
    @Published var categories: [Category] = []
    
    init(networkManager: NetworkService) {
        self.networkManager = networkManager
    }
    
    func fetchCategories () async {
        do {
             let categoriesList = try await networkManager.fetchCategories()
            DispatchQueue.main.async {
                self.categories = categoriesList
            }
        } catch(let error) {
                // log to crashlytics
            print("ERROR: \(error.localizedDescription)")
        }
    }
    
    func fetchProducts () async {
        do {
            let products = try await networkManager.fetchProducts()
            DispatchQueue.main.async { [self] in
                self.products = products
            }
        } catch(let error) {
                // log to crashlytics
            print("ERROR: \(error.localizedDescription)")

        }
    }
    
}

extension ProductListingViewModel {
    static let sampleProduct: Product = Product(id: 1,
                                                title: "Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops",
                                                price: 109.95,
                                                description: "Your perfect pack for everyday use and walks in the forest. Stash your laptop (up to 15 inches) in the padded sleeve, your everyday", category: "men's clothing", image: "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg", rating: Rating(rate: 3.9, count: 120))
}
