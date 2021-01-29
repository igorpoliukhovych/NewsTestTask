//
//  NewsTableCell.swift
//  NewsTestTask
//
//  Created by Igor Poliukhovych on 28.01.2021.
//

import UIKit
import Kingfisher

class NewsTableCell: UITableViewCell {
    
    @IBOutlet private weak var sourceLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var newsIcon: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(withSource model: SourceNews) {
        sourceLabel.text = nil
        authorLabel.text = model.name
        titleLabel.text = nil
        descriptionLabel.text = model.description
    }
    
    func configureCell(withArticle model: Article) {
        
        sourceLabel.text = model.source?.name
        authorLabel.text = model.author
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        
        if let urlString = model.urlToImage, let url = URL(string: urlString) {
            newsIcon.kf.setImage(with: url)
        }
    }
    
}
