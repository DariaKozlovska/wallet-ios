import SwiftUI

struct GitHubApi: View {
    
    let username: String
    
    @State private var user: GitHubUser?
    @State private var repos: [GitHubRepos] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 10) {
            if isLoading {
                ProgressView("Loading...")
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if let user = user {
                // Avatar użytkownika
                AsyncImage(url: URL(string: user.avatarUrl)) { image in
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
                Text(user.name ?? username)
                    .bold()
                    .font(.system(size: 24))
                    .foregroundColor(.primary)

                // Bio użytkownika
                Text(user.bio ?? "No bio available.")
                    .font(.body)
                    .foregroundColor(.secondary)

                // Lokalizacja użytkownika
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                    Text(user.location ?? "Worldwide")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }

                // Followed stats
                HStack(spacing: 15) {
                    Text("\(user.followers) followers")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Text("\(user.following) following")
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
                            .padding(.all, 10)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .listStyle(PlainListStyle())
                }
            }

            Spacer()
        }
        .padding()
        .task {
            await fetchData()
        }
        .navigationTitle("GitHub Profile")
    }
    
    private func fetchData() async {
        do {
            user = try await getUser()
            repos = try await getRepos()
            isLoading = false
        } catch GHError.invalidURL {
            errorMessage = "Invalid URL."
            isLoading = false
        } catch GHError.invalidResponse {
            errorMessage = "Invalid response from server."
            isLoading = false
        } catch GHError.invalidData {
            errorMessage = "Invalid data received."
            isLoading = false
        } catch {
            errorMessage = "Unexpected error occurred."
            isLoading = false
        }
    }

    func getUser() async throws -> GitHubUser {
        let endpoint = "https://api.github.com/users/\(username)"
        
        guard let url = URL(string: endpoint) else {
            throw GHError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(GitHubUser.self, from: data)
    }
    
    func getRepos() async throws -> [GitHubRepos] {
        let endpoint = "https://api.github.com/users/\(username)/repos"
        
        guard let url = URL(string: endpoint) else {
            throw GHError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([GitHubRepos].self, from: data)
    }
}

struct GitHubApi_Previews: PreviewProvider {
    static var previews: some View {
        GitHubApi(username: "octocat")
    }
}

struct GitHubUser: Codable {
    let name: String?
    let avatarUrl: String
    let bio: String?
    let location: String?
    let followers: Int
    let following: Int
}

struct GitHubRepos: Codable, Identifiable {
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
