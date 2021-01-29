//
//  Article.swift
//  NewsTestTask
//
//  Created by Igor Poliukhovych on 28.01.2021.
//

import Foundation

struct Article {
    
    var source: Source?
    var author: String?
    var title: String?
    var description: String?
    var url: String?
    var urlToImage: String?
    var publishedAt: Date?
    
}

struct Source {
    
    let id: String?
    let name: String
    
}
