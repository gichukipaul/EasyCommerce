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
                Task {
                    await vm.fetchProductsFor(category: Category(name: new))
                }
            }
            
            List (vm.products, id: \.self) { product in
                ProductItemView(product: product)
            }
            .listStyle(.plain)
            .task {
                await vm.fetchCategories()
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
