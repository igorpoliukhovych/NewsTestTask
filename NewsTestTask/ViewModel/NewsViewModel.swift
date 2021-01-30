//
//  NewsViewModel.swift
//  NewsTestTask
//
//  Created by Igor Poliukhovych on 30.01.2021.
//

import Foundation

class NewsViewModel {
    
    enum NewsType {
        case source
        case articles
    }
    
    var articles: [Article]?
    var sources: [SourceNews]?
    var newsType: NewsType = .articles
    
    var selectedCountryCode = "ua"
    var selectedCategory = "general"
    let countryDataList = ["ae", "ar", "at", "au", "be", "bg", "br", "ca", "ch", "cn", "co", "cu", "cz", "de", "eg", "fr", "gb", "gr", "hk", "hu", "id", "ie", "il", "in", "it", "jp", "kr", "lt", "lv", "ma", "mx", "my", "ng", "nl", "no", "nz", "ph", "pl", "pt", "ro", "rs", "ru", "sa", "se", "sg", "si", "sk", "th", "tr", "tw", "ua", "us", "ve", "za"]
    let categoryDataList = ["business", "entertainment", "general", "health", "science", "sports", "technology"]

    private var networkService = NetworkManager()
    
    func fetchArticles(q: String? = nil, pageSize: Int, page: Int, completion: @escaping ((Result<Bool, NewsAPIError>) -> Void)) {
        
        networkService.fetchArticles(q: q, countryCode: self.selectedCountryCode, category: self.selectedCategory, pageSize: pageSize, page: page) { result in
            switch result {
            case .success(let articles):
                if let dowloadedArticles = self.articles, !dowloadedArticles.isEmpty {
                    self.articles?.append(contentsOf: articles)
                } else {
                    self.articles = articles
                }
                self.articles?.sort(by: { firstDate, secondDate in
                                        guard let firstDate = firstDate.publishedAt, let secondDate = secondDate.publishedAt else { return false }
                                        return  firstDate > secondDate})
                print("Uploaded")
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchSources(completion: @escaping ((Result<Bool, NewsAPIError>) -> Void)) {
        
        networkService.fetchSources(countryCode: selectedCountryCode, category: selectedCategory) { result in
            switch result {
            case .success(let sources):
                if let dowloadedSources = self.sources, !dowloadedSources.isEmpty {
                    self.sources?.append(contentsOf: sources)
                } else {
                    self.sources = sources
                }
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
}
