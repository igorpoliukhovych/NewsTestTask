//
//  UITableView+Extension.swift
//  NewsTestTask
//
//  Created by Igor Poliukhovych on 27.01.2021.
//

import UIKit

extension UITableView {

    func register <T: UITableViewCell>(nibCell identifier: T.Type) {
        let identifierString = String(describing: identifier)
        let nib = UINib(nibName: identifierString, bundle: nil)
        register(nib, forCellReuseIdentifier: identifierString)
    }

    func register <T: UITableViewCell>(class identifier: T.Type) {
        let identifierString = String(describing: identifier)
        register(T.self, forCellReuseIdentifier: identifierString)
    }
}

extension UITableView {

    func dequeue <T: UITableViewCell>(reusable identifier: T.Type) -> T {
        let identifierString = String(describing: identifier)
        return self.dequeueReusableCell(withIdentifier: identifierString) as! T
    }

    func dequeue <T: UITableViewCell>(reusable identifier: T.Type, for indexPath: IndexPath) -> T {
        let identifierString = String(describing: identifier)
        return self.dequeueReusableCell(withIdentifier: identifierString, for: indexPath) as! T
    }
}
