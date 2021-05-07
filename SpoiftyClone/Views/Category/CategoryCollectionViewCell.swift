//
//  CategoryCollectionViewCell.swift
//  SpoiftyClone
//
//  Created by Aakash Kumar on 27/04/21.
//

import UIKit
import SDWebImage

class CategoryCollectionViewCell: UICollectionViewCell {
    static let identifier = "CategoryCollectionViewCell"
    
    private let musicImageLabel : UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let textLabel : UILabel  = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.clipsToBounds = true
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        contentView.addSubview(musicImageLabel)
        contentView.addSubview(textLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let textLabelSize = textLabel.sizeThatFits(CGSize(width: contentView.width - 40, height: (contentView.height / 3.0)))
        
        textLabel.frame = CGRect(x: (contentView.width - textLabelSize.width ) / 2.0,
                                 y: contentView.height - textLabelSize.height,
                                 width: textLabelSize.width,
                                 height: textLabelSize.height)
        
        musicImageLabel.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel.text = nil
    }
    
    func configureCell(viewModel: CategoryViewCellViewModel) {
        textLabel.text = viewModel.label
        musicImageLabel.sd_setImage(with: viewModel.url, completed: nil)
    }
}
