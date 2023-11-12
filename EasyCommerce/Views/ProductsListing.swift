//
//  ProductsListing.swift
//  EasyCommerce
//
//  Created by Gichuki on 12/11/2023.
//

import SwiftUI

struct ProductsListing: View {
    
    @StateObject private var vm: ProductListingViewModel = ProductListingViewModel(networkManager: NetworkManager.shared)
    
    var body: some View {
        List (vm.products, id: \.self) { product in
            ProductItemView(product: product)
        }
        .listStyle(.plain)
        .onAppear {
            Task {
                await vm.fetchProducts()
            }
        }
    }
}

struct ProductsListing_Previews: PreviewProvider {
    static var previews: some View {
        ProductsListing()
    }
}
