//
//  ContentView.swift
//  EasyCommerce
//
//  Created by Gichuki on 12/11/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ProductsListing()
                .padding()
                .navigationTitle("Products")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
