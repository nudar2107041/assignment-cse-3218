//
//  newsinfo.swift
//  news
//

import Foundation

// Represents a single article
struct Article: Codable, Identifiable {
    var id: UUID { UUID() }
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
}

// Represents the article's source
struct Source: Codable {
    let id: String?
    let name: String
}

// Represents the API response
struct NewsResponse: Codable {
    let totalResults: Int
    let status: String
    var articles: [Article]
}

// Represents a selectable country
struct NewsCountry: Identifiable, Hashable {
    let id: String       // Country code used by News API (e.g. "us")
    let name: String     // Full country name shown in UI (e.g. "United States")

    // Supported countries by News API top-headlines endpoint
    static let all: [NewsCountry] = [
        NewsCountry(id: "ae", name: "United Arab Emirates"),
        NewsCountry(id: "ar", name: "Argentina"),
        NewsCountry(id: "at", name: "Austria"),
        NewsCountry(id: "au", name: "Australia"),
        NewsCountry(id: "be", name: "Belgium"),
        NewsCountry(id: "bg", name: "Bulgaria"),
        NewsCountry(id: "br", name: "Brazil"),
        NewsCountry(id: "ca", name: "Canada"),
        NewsCountry(id: "ch", name: "Switzerland"),
        NewsCountry(id: "cn", name: "China"),
        NewsCountry(id: "co", name: "Colombia"),
        NewsCountry(id: "cu", name: "Cuba"),
        NewsCountry(id: "cz", name: "Czech Republic"),
        NewsCountry(id: "de", name: "Germany"),
        NewsCountry(id: "eg", name: "Egypt"),
        NewsCountry(id: "fr", name: "France"),
        NewsCountry(id: "gb", name: "United Kingdom"),
        NewsCountry(id: "gr", name: "Greece"),
        NewsCountry(id: "hk", name: "Hong Kong"),
        NewsCountry(id: "hu", name: "Hungary"),
        NewsCountry(id: "id", name: "Indonesia"),
        NewsCountry(id: "ie", name: "Ireland"),
        NewsCountry(id: "il", name: "Israel"),
        NewsCountry(id: "in", name: "India"),
        NewsCountry(id: "it", name: "Italy"),
        NewsCountry(id: "jp", name: "Japan"),
        NewsCountry(id: "kr", name: "South Korea"),
        NewsCountry(id: "lt", name: "Lithuania"),
        NewsCountry(id: "lv", name: "Latvia"),
        NewsCountry(id: "ma", name: "Morocco"),
        NewsCountry(id: "mx", name: "Mexico"),
        NewsCountry(id: "my", name: "Malaysia"),
        NewsCountry(id: "ng", name: "Nigeria"),
        NewsCountry(id: "nl", name: "Netherlands"),
        NewsCountry(id: "no", name: "Norway"),
        NewsCountry(id: "nz", name: "New Zealand"),
        NewsCountry(id: "ph", name: "Philippines"),
        NewsCountry(id: "pl", name: "Poland"),
        NewsCountry(id: "pt", name: "Portugal"),
        NewsCountry(id: "ro", name: "Romania"),
        NewsCountry(id: "rs", name: "Serbia"),
        NewsCountry(id: "ru", name: "Russia"),
        NewsCountry(id: "sa", name: "Saudi Arabia"),
        NewsCountry(id: "se", name: "Sweden"),
        NewsCountry(id: "sg", name: "Singapore"),
        NewsCountry(id: "si", name: "Slovenia"),
        NewsCountry(id: "sk", name: "Slovakia"),
        NewsCountry(id: "th", name: "Thailand"),
        NewsCountry(id: "tr", name: "Turkey"),
        NewsCountry(id: "tw", name: "Taiwan"),
        NewsCountry(id: "ua", name: "Ukraine"),
        NewsCountry(id: "us", name: "United States"),
        NewsCountry(id: "ve", name: "Venezuela"),
        NewsCountry(id: "za", name: "South Africa")
    ]
}

class ArticleViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedCountry: NewsCountry = NewsCountry(id: "us", name: "United States")

    private let apiKey = "ac3d3dcbcadb4f7cabca1f7f2b46f8af"

    /// Fetch Tesla articles for the currently selected country
    func fetchArticles() {
        let urlString = "https://newsapi.org/v2/top-headlines?q=tesla&country=\(selectedCountry.id)&apiKey=\(apiKey)"

        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid API URL."
            return
        }

        self.isLoading = true
        self.errorMessage = nil

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Failed to fetch articles: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received from the server."
                    return
                }

                do {
                    let decodedResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
                    self.articles = decodedResponse.articles
                } catch {
                    print("Failed to decode articles: \(error)")
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Received JSON: \(jsonString)")
                    }
                    self.errorMessage = "Failed to decode articles: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    /// Call this when the user picks a new country
    func changeCountry(to country: NewsCountry) {
        selectedCountry = country
        fetchArticles()
    }
}
