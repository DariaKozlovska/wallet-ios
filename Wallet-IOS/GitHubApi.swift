//
//  GitHubApi.swift
//  Wallet-IOS
//
//  Created by Daria Kozlovska on 28/03/2025.
//

import SwiftUI

struct gitHubApi: View {
    
    @State private var user: GitHubUser?
    @State private var repos: [GitHubRepos] = []
    
    var body: some View {
        VStack(spacing: 10) {
            // Avatar użytkownika
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
            }
            .frame(width: 120, height: 120)

            // Imię użytkownika
            Text(user?.name ?? "Login placeholder")
                .bold()
                .font(.system(size: 24))
                .foregroundColor(.primary) // Kolor tekstu

            // Bio użytkownika
            Text(user?.bio ?? "No bio available.")
                .font(.body)
                .foregroundColor(.secondary)

            // Lokalizacja użytkownika
            HStack(spacing: 8) {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                Text(user?.location ?? "Worldwide")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }

            // Followed stats
            HStack(spacing: 15) {
                Text("\(user?.followers ?? 0) followers")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text("\(user?.following ?? 0) followings")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }

            Divider()
                .padding(.top, 15)
            
            // Repozytoria użytkownika
            Text("Repositories")
                .bold()
                .font(.system(size: 22))
                .foregroundColor(.primary)
                .padding(.top, 10)

            // Lista repozytoriów
            if repos.isEmpty {
                Text("No repositories available.")
                    .foregroundColor(.gray)
                    .italic()
                    .padding(.top, 10)
            } else {
                List(repos) { repo in
                    Link(destination: URL(string: repo.cloneUrl)!) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(repo.name)
                                .font(.headline)
                                .foregroundColor(.primary)

                            HStack {
                                Text(repo.visibility ?? "Public")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(repo.language ?? "Unknown")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }

                            Text(repo.description ?? "No description")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        .padding(.all, 20)
                        .background(Color(UIColor.systemBackground)) // Tło dla całego bloku
                        .cornerRadius(10) // Zaokrąglone rogi
                        .shadow(radius: 5) // Cień dla efektu głębi
                    }
                    .buttonStyle(PlainButtonStyle()) // Usunięcie standardowego wyglądu przycisku
                }
                .listStyle(PlainListStyle())

            }
            
            Spacer()
        }
        .padding()


        .task {
            do{
                user = try await getUser()
                repos = try await getRepos()
            }catch GHError.invalidURL{
                print("Invalid URL")
            }catch GHError.invalidResponse{
                print("Invalid Response")
            }catch GHError.invalidData{
                print("Invalid Data")
            }catch {
                print("unexpected error")
            }
        }
    }
    
    func getUser() async throws -> GitHubUser {
        let endpoint = "https://api.github.com/users/DariaKozlovska"
        
        guard let url = URL(string: endpoint) else {
            throw GHError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        do{
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        } catch{
            print("Error decoding data: \(error)")
            throw GHError.invalidData
        }
    }
    
    func getRepos() async throws -> [GitHubRepos]{
        let endpoint = "https://api.github.com/users/DariaKozlovska/repos"
        
        guard let url = URL(string: endpoint) else {
            throw GHError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
            throw GHError.invalidResponse
        }
        
        do{
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode([GitHubRepos].self, from: data)
        }catch {
            throw GHError.invalidData
        }
    }
}

struct gitHubApi_Previews: PreviewProvider{
    static var previews: some View{
        gitHubApi()
    }
}

struct GitHubUser: Codable{
    let name: String
    let avatarUrl: String
    let bio: String?
    let location: String
    let followers: Int
    let following: Int
    let reposUrl: String
}

struct GitHubRepos: Codable, Identifiable{
    let id: Int
    let name: String
    let description: String?
    let visibility: String?
    let language: String?
    let cloneUrl: String
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
