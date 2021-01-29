//
//  ArticleWebViewConntroller.swift
//  NewsTestTask
//
//  Created by Igor Poliukhovych on 28.01.2021.
//

import UIKit
import WebKit

class ArticleWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    lazy var backButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.back(_:)))
    }()
    
    var urlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavItem()
        if let urlString = urlString, let myURL = URL(string: urlString) {
            let myRequest = URLRequest(url: myURL)
            webView.load(myRequest)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            webView.leftAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            webView.bottomAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            webView.rightAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor)
        ])
    }
    
    private func setupNavItem() {
        self.navigationItem.leftBarButtonItem = backButton
    }
        
    private func setupNavBar() {
        self.navigationController?.navigationBar.barTintColor = .systemBlue
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func back(_ sender: AnyObject?) {
        dismiss(animated: true, completion: nil)
    }
}
