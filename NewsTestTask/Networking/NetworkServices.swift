//
//  NetworkServices.swift
//  NewsTestTask
//
//  Created by Igor Poliukhovych on 28.01.2021.
//

import Foundation

let API_URL = "https://newsapi.org/v2/top-headlines"
let API_URL_SOURCE = "https://newsapi.org/v2/sources"
let API_Key = "af334fdcfaeb4c3fa750b59317ae9e45"

class NetworkManager {
    
    func fetchSources(countryCode: String,
                      category: String?,
                      completion: @escaping ((Result<[SourceNews], NewsAPIError>) -> Void)) {
        
        var sources = [SourceNews]()
        
        var components = URLComponents(string: API_URL_SOURCE)!
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "country", value: countryCode))
        
        if let category = category {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }
        
        queryItems.append(URLQueryItem(name: "language", value: "en"))
        queryItems.append(URLQueryItem(name: "apiKey", value: API_Key))
        components.queryItems = queryItems
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        guard let componentUrl = components.url else { return completion(.failure(.invalidEndpointUrl)) }
        
        let request = URLRequest(url: componentUrl)
        
        let task = URLSession.shared.dataTask(with: request) { (data, responce, error) in
            if error != nil {
                completion(.failure(.serviceError(code: "", message: error?.localizedDescription ?? "")))
            }
            guard let data = data else { return completion(.failure(.unableToParse))}
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: AnyObject]
                
                if let sourcesFromJson = json["sources"] as? [[String: AnyObject?]] {
                    for sourceFromJson in sourcesFromJson {
                        if let id = sourceFromJson["id"] as? String?,
                           let name = sourceFromJson["name"] as? String?,
                           let description = sourceFromJson["description"] as? String?,
                           let url = sourceFromJson["url"] as? String?,
                           let category = sourceFromJson["category"] as? String?,
                           let language = sourceFromJson["language"] as? String?,
                           let country = sourceFromJson["country"] as? String? {
                            
                            let source = SourceNews(id: id,
                                                    name: name,
                                                    description: description,
                                                    url: url,
                                                    category: category,
                                                    language: language,
                                                    country: country)
                            
                            sources.append(source)
                        }
                    }
                    completion(.success(sources))
                } else {
                    let errorCode = json["code"] as? String ?? ""
                    let errorMessage = json["message"] as? String ?? ""
                    completion(.failure(.serviceError(code: errorCode, message: errorMessage)))
                }
            } catch let error {
                print(error)
                completion(.failure(.requestFailed))
            }
            
        }
        
        task.resume()
        
    }
    
    func fetchArticles(q: String?,
                       countryCode: String,
                       category: String?,
                       pageSize: Int,
                       page: Int,
                       completion: @escaping ((Result<[Article], NewsAPIError>) -> Void)) {
        
        var articles = [Article]()
        
        var components = URLComponents(string: API_URL)!
        var queryItems = [URLQueryItem]()
        
        if let q = q {
            queryItems.append(URLQueryItem(name: "q", value: q))
        }
        queryItems.append(URLQueryItem(name: "country", value: countryCode))
        
        if let category = category {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }
        
        queryItems.append(URLQueryItem(name: "pageSize", value: "\(pageSize)"))
        queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
        queryItems.append(URLQueryItem(name: "apiKey", value: API_Key))
        components.queryItems = queryItems
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        guard let componentUrl = components.url else { return completion(.failure(.invalidEndpointUrl)) }
    
        let request = URLRequest(url: componentUrl)
        
        let task = URLSession.shared.dataTask(with: request) { (data, responce, error) in
            
            if error != nil {
                completion(.failure(.serviceError(code: "", message: error?.localizedDescription ?? "")))
            }
            guard let data = data else { return completion(.failure(.unableToParse))}
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: AnyObject]
                
                if let articlesFromJson = json["articles"] as? [[String: AnyObject?]] {
                    for articleFromJson in articlesFromJson {
                        var article = Article()
                        if let author = articleFromJson["author"] as? String?,
                           let title = articleFromJson["title"] as? String?,
                           let description = articleFromJson["description"] as? String?,
                           let url = articleFromJson["url"] as? String?,
                           let urlToImage = articleFromJson["urlToImage"] as? String?,
                           let publishedAt = articleFromJson["publishedAt"] as? String?,
                           let source = articleFromJson["source"] as? [String: AnyObject?]?,
                           let sourceName = source?["name"] as? String? {
                            
                            article.source = Source(id: nil, name: sourceName ?? "")
                            article.author = author
                            article.title = title
                            article.description = description
                            article.url = url
                            article.urlToImage = urlToImage
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
                            let date = dateFormatter.date(from: publishedAt ?? "")
                            
                            article.publishedAt = date
                            articles.append(article)
                        }
                    }
                    completion(.success(articles))
                } else {
                    let errorCode = json["code"] as? String ?? ""
                    let errorMessage = json["message"] as? String ?? ""
                    completion(.failure(.serviceError(code: errorCode, message: errorMessage)))
                }
            } catch let error {
                print(error)
                completion(.failure(.requestFailed))
            }
        }
        task.resume()
    }
    
    
}
