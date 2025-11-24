//
//  ProductItemView.swift
//  EasyCommerce
//
//  Created by Gichuki on 12/11/2023.
//

import SwiftUI

struct ProductItemView: View {
    let product: Product
    
    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: product.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 130, height: 130)
                    .cornerRadius(8)
            } placeholder: {
                ProgressView()
                    .tint(.red)
                    .frame(width: 130, height: 130)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.headline.weight(.bold))
                
                Spacer()
                Text("Price: $\(String(format: "%.2f", product.price))")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
        }
    }
}

struct ProductItemView_Previews: PreviewProvider {
    static var previews: some View {
        ProductItemView(product: ProductListingViewModel.sampleProduct)
    }
}
