//
//  ContentView.swift
//  Wallet-IOS
//
//  Created by Daria Kozlovska on 28/03/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            Tab("GitHub", systemImage: "person.crop.circle"){
                GitHub()
            }
        }
    }
}

#Preview {
    ContentView()
}
