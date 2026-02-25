//
//  ContentView.swift
//  news
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ArticleViewModel()
    @State private var showCountryPicker = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

                // ── Country selector bar ──────────────────────────────────
                Button(action: { showCountryPicker = true }) {
                    HStack {
                        Text("Country:")
                            .foregroundColor(.primary)
                            .fontWeight(.medium)
                        Text(viewModel.selectedCountry.name)
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                        Image(systemName: "chevron.down")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                }

                Divider()

                // ── Main content ──────────────────────────────────────────
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading Articles...")
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage {
                    Spacer()
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else if viewModel.articles.isEmpty {
                    Spacer()
                    Text("No Tesla news found for \(viewModel.selectedCountry.name).")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else {
                    List(viewModel.articles) { article in
                        NavigationLink(destination: ArticleDetailView(
                            article: article,
                            countryName: viewModel.selectedCountry.name)
                        ) {
                            ArticleRowView(
                                article: article,
                                countryName: viewModel.selectedCountry.name
                            )
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Tesla News")
            .onAppear {
                viewModel.fetchArticles()
            }
            // ── Country picker sheet ──────────────────────────────────────
            .sheet(isPresented: $showCountryPicker) {
                CountryPickerView(
                    selectedCountry: viewModel.selectedCountry,
                    onSelect: { country in
                        viewModel.changeCountry(to: country)
                        showCountryPicker = false
                    }
                )
            }
        }
    }
}

// ── Article row ───────────────────────────────────────────────────────────────
struct ArticleRowView: View {
    let article: Article
    let countryName: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Thumbnail
            if let imageUrl = article.urlToImage, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 70)
                        .cornerRadius(8)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 70, height: 70)
                        .cornerRadius(8)
                        .overlay(ProgressView())
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 70, height: 70)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "newspaper")
                            .foregroundColor(.gray)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(article.source.name)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // Country name label
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text(countryName)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// ── Article detail ────────────────────────────────────────────────────────────
struct ArticleDetailView: View {
    let article: Article
    let countryName: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                // Hero image
                if let imageUrl = article.urlToImage, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(10)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(maxWidth: .infinity, maxHeight: 200)
                            .cornerRadius(10)
                            .overlay(ProgressView())
                    }
                }

                // Title
                Text(article.title)
                    .font(.title2)
                    .fontWeight(.bold)

                // Country name
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.blue)
                    Text("Country: \(countryName)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 10)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)

                // Author
                Text("By \(article.author ?? "Unknown Author")")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // Description
                Text(article.description ?? "No description available.")
                    .font(.body)

                // Read more link
                if let url = URL(string: article.url) {
                    Link(destination: url) {
                        HStack {
                            Text("Read Full Article")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.up.right.square")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(article.source.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ── Country picker sheet ──────────────────────────────────────────────────────
struct CountryPickerView: View {
    let selectedCountry: NewsCountry
    let onSelect: (NewsCountry) -> Void

    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss

    var filteredCountries: [NewsCountry] {
        if searchText.isEmpty {
            return NewsCountry.all
        }
        return NewsCountry.all.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            List(filteredCountries) { country in
                Button(action: { onSelect(country) }) {
                    HStack {
                        Text(country.name)
                            .foregroundColor(.primary)
                        Spacer()
                        if country.id == selectedCountry.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search country")
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
