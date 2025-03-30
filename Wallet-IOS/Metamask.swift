//
//  Metamask.swift
//  Wallet-IOS
//
//  Created by Daria Kozlovska on 30/03/2025.
//

import SwiftUI

struct MainView: View {
    @State private var walletAddress: String = ""
    @State private var navigateToWallet = false
    
    var body: some View {
        NavigationView{
            VStack{
                Text("Enter wallet address")
                    .font(.system(size: 24))
                    .bold()
                    .padding()
                
                TextField("GitHub Username", text: $walletAddress)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: walletAddress) {
                        walletAddress = walletAddress.replacingOccurrences(of: " ", with: "")
                    }
                
                Button(action: {
                    if !walletAddress.isEmpty {
                        navigateToWallet = true
                    }
                }) {
                    Text("Go to Wallet")
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
            //            .navigationDestination(isPresented: $navigateToWallet) {
            //                GitHubApi(username: username)
            //            }
            
        }
    }
}


struct MainView_Preview: PreviewProvider{
    static var previews: some View {
        MainView()
    }
}
