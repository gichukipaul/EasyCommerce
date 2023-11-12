//
//  ProductsListing.swift
//  EasyCommerce
//
//  Created by Gichuki on 12/11/2023.
//

import SwiftUI

struct ProductsListing: View {
    
    @StateObject private var vm: ProductListingViewModel = ProductListingViewModel(networkManager: NetworkManager.shared)
    @State private var selected: String = ""
    
    var body: some View {
        VStack {
            Picker(selection: $selected, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/) {
                Text("All").tag("All")
                ForEach(vm.categories, id: \.self) { category in
                    Text("\(category.name)").tag(category.name)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selected ) { new in
                    // TODO: SHOW PRODUCTS BASED ON SELECTION
                print(selected)
            }
            
            
            
            List (vm.products, id: \.self) { product in
                ProductItemView(product: product)
            }
            .listStyle(.plain)
            .onAppear {
                Task {
                    do {
                        try await vm.fetchCategories()
                        try await vm.fetchProducts()
                    } catch {
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

struct ProductsListing_Previews: PreviewProvider {
    static var previews: some View {
        ProductsListing()
    }
}
