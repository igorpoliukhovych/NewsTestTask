//
//  MainNewsViewController.swift
//  NewsTestTask
//
//  Created by Igor Poliukhovych on 28.01.2021.
//

import UIKit

final class MainNewsViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    
    @IBOutlet private weak var tableView: UITableView! {
        willSet {
            newValue.register(nibCell: NewsTableCell.self)
        }
    }
    @IBOutlet private weak var countryTextField: UITextField!
    @IBOutlet private weak var sourceTextField: UITextField!
    @IBOutlet private weak var categotyTextField: UITextField!
    
    private enum NewsType {
        case source
        case articles
    }
    
    private var newsType: NewsType = .articles
    
    private var activeEdit: UIView?
    
    private var selectedCountryCode: String?
    private var selectedCategory: String?
    private var articles: [Article]?
    private var sources: [SourceNews]?
    private var networkManager = NetworkManager()
    private var searchTask: DispatchWorkItem?
    
    private lazy var paginator: Paginator = {
        return Paginator(pagination: (page: 1, limit: 5)) { [unowned self] in
            self.getArticles(countryCode: self.selectedCountryCode ?? "ua", category: self.selectedCategory)
        }
    }()
    
    private let countryDataList = ["ae", "ar", "at", "au", "be", "bg", "br", "ca", "ch", "cn", "co", "cu", "cz", "de", "eg", "fr", "gb", "gr", "hk", "hu", "id", "ie", "il", "in", "it", "jp", "kr", "lt", "lv", "ma", "mx", "my", "ng", "nl", "no", "nz", "ph", "pl", "pt", "ro", "rs", "ru", "sa", "se", "sg", "si", "sk", "th", "tr", "tw", "ua", "us", "ve", "za"]
    
    private let categoryDataList = ["business", "entertainment", "general", "health", "science", "sports", "technology"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        countryTextField.delegate = self
        sourceTextField.delegate = self
        categotyTextField.delegate = self
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search news..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        paginator.resetPagination()
        
        let tableViewRefreshControl = UIRefreshControl()
        tableViewRefreshControl.attributedTitle = NSAttributedString(string: "Pull down to refresh")
        tableViewRefreshControl.addTarget(self, action: #selector(self.refreshControlTrigger(_:)), for: .valueChanged)
        tableView.addSubview(tableViewRefreshControl)
        
        configurePicker(forTextField: countryTextField)
        configurePicker(forTextField: categotyTextField)
        countryTextField.text = "ua"
        categotyTextField.text = "business"
        sourceTextField.text = "sources"
        selectedCountryCode = "ua"
        selectedCategory = "business"
        getArticles(countryCode: "ua", category: selectedCategory)
    }
    
    
    @objc private func refreshControlTrigger(_ sender: UIView?) {
        if let control = sender as? UIRefreshControl {
            paginator.resetPagination()
            articles = nil
            sources = nil
            switch newsType {
            case .articles:
                getArticles(countryCode: selectedCountryCode ?? "ua", category: selectedCategory)
            case .source:
                getSourcesList()
            }
            control.endRefreshing()
        }
    }
    
    private func getSourcesList() {
        sourceTextField.resignFirstResponder()
        
        guard let countryCode = selectedCountryCode, let category = selectedCategory else { return }
        networkManager.fetchSources(countryCode: countryCode, category: category) { result in
            switch result {
            case .success(let sources):
                self.getSourcesDidSucceed(sources: sources)
            case .failure(let error):
                self.getListDidFailed(error: error)
            }
        }
    }
    
    private func getSourcesDidSucceed(sources: [SourceNews]) {
        if let dowloadedSources = self.sources, !dowloadedSources.isEmpty {
            self.sources?.append(contentsOf: sources)
        } else {
            self.sources = sources
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func getArticles(countryCode: String, category: String?) {
        
        let pageSize = paginator.pagination.limit
        let page = paginator.pagination.page
        
        networkManager.fetchArticles(q: nil, countryCode: countryCode, category: category, pageSize: pageSize, page: page) { result in
            switch result {
            case .success(let articles):
                self.getArticlesDidSucceed(articles: articles)
            case .failure(let error):
                self.getListDidFailed(error: error)
            }
        }
    }
    
    private func getArticlesDidSucceed(articles: [Article]) {
        if let dowloadedArticles = self.articles, !dowloadedArticles.isEmpty {
            self.articles?.append(contentsOf: articles)
        } else {
            self.articles = articles
        }
        self.articles?.sort(by: { firstDate, secondDate in
                                guard let firstDate = firstDate.publishedAt, let secondDate = secondDate.publishedAt else { return false }
                                return  firstDate > secondDate})
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func getListDidFailed(error: NewsAPIError) {
        DispatchQueue.main.async {
            self.showMessage(title: nil, text: error.errorDescription, animated: true)
        }
    }
    
    
    private func showMessage(title: String?, text: String?,
                             animated: Bool, parentViewController: UIViewController? = nil,
                             actionList: [UIAlertAction]? = nil, showOkActionIfNoOtherActions: Bool = true) {
        
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        if let actionList = actionList, !actionList.isEmpty {
            for action in actionList {
                alertController.addAction(action)
            }
        } else if showOkActionIfNoOtherActions {
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        }
        
        let parentVC: UIViewController = parentViewController ?? self
        parentVC.present(alertController, animated: animated, completion: nil)
    }
    
    func configurePicker(forTextField textField: UITextField) {
        let picker = UIPickerView()
        textField.inputView = picker
        picker.delegate = self
        picker.dataSource = self
        
        let toolBar: UIToolbar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 44.0))
        let flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action:#selector(self.pickerCancelSelection))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action:#selector(self.pickerConfirmSelection))
        let fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        toolBar.setItems([flexibleSpaceButton, cancelButton, doneButton, fixedSpaceButton], animated: false)
        textField.inputAccessoryView = toolBar
    }
    
    @objc private func pickerCancelSelection(_ sender: UIBarButtonItem?) {
        if let textField = activeEdit as? UITextField {
            textField.resignFirstResponder()
        }
    }
    
    @objc private func pickerConfirmSelection(_ sender: UIBarButtonItem?) {
        if let textField = activeEdit as? UITextField {
            
            switch textField {
            case countryTextField:
                guard let selectedCountryCode = selectedCountryCode else {
                    textField.resignFirstResponder()
                    return
                }
                countryTextField.text = selectedCountryCode
                paginator.resetPagination()
                articles = nil
                getArticles(countryCode: selectedCountryCode, category: selectedCategory)
            case categotyTextField:
                guard let selectedCategoty = selectedCategory else {
                    textField.resignFirstResponder()
                    return
                }
                categotyTextField.text = selectedCategoty
                paginator.resetPagination()
                articles = nil
                getArticles(countryCode: selectedCountryCode!, category: selectedCategory)
            default:
                break
            }
            textField.resignFirstResponder()
        }
    }
    
    private func pickerSelection(textField: UITextField, dataList: [String]) {
        if let picker = textField.inputView as? UIPickerView {
            for (index, value) in dataList.enumerated() {
                if selectedCountryCode == value {
                    picker.selectRow(index, inComponent: 0, animated: true)
                }
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text,
              !searchText.isEmpty,
              newsType == .articles else { return }
        
        searchTask?.cancel()
        
        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            self.paginator.resetPagination()
            self.performSearch(request: searchText)
        }
        
        searchTask = task
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: task)
    }
    
    func performSearch(request: String) {
        guard let countryCode = selectedCountryCode,
              let category = selectedCategory else { return }
        
        let pageSize = paginator.pagination.limit
        let page = paginator.pagination.page
        self.articles = []
        
        networkManager.fetchArticles(q: request, countryCode: countryCode, category: category, pageSize: pageSize, page: page) { result in
            switch result {
            case .success(let articles):
                self.getArticlesDidSucceed(articles: articles)
            case .failure(let error):
                self.getListDidFailed(error: error)
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}


extension MainNewsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch newsType {
        case .articles:
            return articles?.count ?? 0
        case .source:
            return sources?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(reusable: NewsTableCell.self, for: indexPath)
        
        switch newsType {
        case .articles:
            guard let article = articles else { return UITableViewCell() }
            cell.configureCell(withArticle: article[indexPath.row])
        case .source:
            guard let sources = sources else { return UITableViewCell() }
            cell.configureCell(withSource: sources[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let articles = articles else { return }
        
        guard articles.count != 0,
              indexPath.row > articles.count - 2,
              indexPath.row > paginator.latestDisplayedItemIndex else {
            self.tableView.tableFooterView = UIView()
            return
        }
        
        guard articles.count % paginator.pagination.limit == 0 else {
            self.tableView.tableFooterView = UIView()
            return
        }
        
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.startAnimating()
        spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        
        self.tableView.tableFooterView = spinner
        self.tableView.tableFooterView?.isHidden = false
        
        paginator.handleItemAppearance(totalItems: articles.count,
                                       indexOfItemInTable: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

extension MainNewsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewController = ArticleWebViewController()
        switch newsType {
        case .articles:
            guard let articles = articles else { return }
            viewController.urlString = articles[indexPath.row].url
        case .source:
            guard let sources = sources  else { return }
            viewController.urlString = sources[indexPath.row].url
        }
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
}

extension MainNewsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeEdit = textField
        
        switch textField {
        case countryTextField:
            newsType = .articles
            pickerSelection(textField: textField, dataList: countryDataList)
        case sourceTextField:
            newsType = .source
            getSourcesList()
        default:
            pickerSelection(textField: textField, dataList: categoryDataList)
            newsType = .articles
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeEdit = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeEdit = nil
    }
    
}

extension MainNewsViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let textField = activeEdit as? UITextField else { return 0 }
        
        switch textField {
        case countryTextField:
            return countryDataList.count
        default:
            return categoryDataList.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let textField = activeEdit as? UITextField else { return nil }
        
        switch textField {
        case countryTextField:
            return countryDataList[row]
        case categotyTextField:
            return categoryDataList[row]
        default:
            return nil
        }
    }
    
}

extension MainNewsViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let textField = activeEdit as? UITextField {
            switch textField {
            case countryTextField:
                selectedCountryCode = countryDataList[row]
            case categotyTextField:
                selectedCategory = categoryDataList[row]
            default:
                break
            }
        }
    }
}

