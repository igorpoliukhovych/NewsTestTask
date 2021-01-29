//
//  Paginator.swift
//  NewsTestTask
//
//  Created by Igor Poliukhovych on 27.01.2021.
//

import Foundation

final class Paginator {

    private(set) var pagination = (page: 1, limit: 5)
    
    private(set) var latestDisplayedItemIndex = 0
    
    var paginationRequest: () -> Void
    
    init(pagination: (page: Int, limit: Int) = (page: 1, limit: 5),
         paginationRequest: @escaping () -> Void) {
        
        self.pagination = pagination
        self.paginationRequest = paginationRequest
    }
    
    private func requestMore() {
        pagination.page += 1
        paginationRequest()
    }
    
    func handleItemAppearance(totalItems: Int, indexOfItemInTable: Int) {
        guard totalItems != 0,
              indexOfItemInTable > totalItems - 2,
              indexOfItemInTable > latestDisplayedItemIndex else {
            return
        }
        latestDisplayedItemIndex = totalItems - 1
        guard totalItems % pagination.limit == 0 else {
            return
        }
        requestMore()
    }
    
    func resetPagination() {
        pagination.page = 1
        latestDisplayedItemIndex = 0
    }
    
}
