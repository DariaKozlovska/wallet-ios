//
//  GitHub.swift
//  Wallet-IOS
//
//  Created by Daria Kozlovska on 30/03/2025.
//

import SwiftUI

struct GitHub: View {
    
    @State private var username: String = ""
    @State private var navigateToProfile: Bool = false
    
    var body: some View {
        NavigationStack {  // 🆕 Używamy NavigationStack
            VStack {
                Text("Enter GitHub Username")
                    .font(.system(size: 24))
                    .bold()
                    .padding()
                
                TextField("GitHub Username", text: $username)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: username) {
                        username = username.replacingOccurrences(of: " ", with: "")
                    }
                
                Button(action: {
                    if !username.isEmpty {
                        navigateToProfile = true
                    }
                }) {
                    Text("Go to GitHub Profile")
                        .font(.system(size: 20))
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $navigateToProfile) {  
                GitHubApi(username: username)
            }
        }
    }
}

#Preview {
    GitHub()
}
