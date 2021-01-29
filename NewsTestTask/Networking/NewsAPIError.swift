//
//  NewsAPIError.swift
//  NewsTestTask
//
//  Created by Igor Poliukhovych on 28.01.2021.
//

import Foundation

enum NewsAPIError: Error {
    case unknown
    case unableToParse
    case requestFailed
    case invalidEndpointUrl
    case serviceError(code: String, message: String)
}

extension NewsAPIError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "An unexpected error has occurred"
        case .unableToParse:
            return "Unable to parse data"
        case .requestFailed:
            return "Server is not reachable"
        case .invalidEndpointUrl:
            return "Please cheack url"
        case .serviceError(_, let message):
            return message
        }
    }
    
}
