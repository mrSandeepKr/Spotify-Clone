//
//  DefaultSearchResultTableViewCell.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 28/04/21.
//

import UIKit
import SDWebImage

struct DefaultSearchResultTableViewCellViewModel {
    let title: String
    let artWorkUrl: URL?
    let subtitle: String?
    let shouldIndicateOfTrackView: Bool
    
    init(title: String, artWorkUrl: URL?, subtitle: String?,shouldIndicateOfTrackView: Bool = true) {
        self.title = title
        self.artWorkUrl = artWorkUrl
        self.subtitle = subtitle
        self.shouldIndicateOfTrackView = shouldIndicateOfTrackView
    }
}

class DefaultSearchResultTableViewCell: UITableViewCell {
    static let identifier = "DefaultSearchResultTableViewCell"
    
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .label
        return label
    }()
    
    private let subtileLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let imageViewBox : UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 2
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let rightIconView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .label
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(titleLabel)
        addSubview(imageViewBox)
        addSubview(subtileLabel)
        addSubview(rightIconView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.sizeToFit()
        subtileLabel.sizeToFit()
        
        let rightIconSize: CGFloat = 15.0
        let titleLabelSize = titleLabel.sizeThatFits(CGSize(width: contentView.width - imageViewBox.width - rightIconSize - 16, height: contentView.height / 1.5 ))
        
        imageViewBox.frame = CGRect(x: 2,
                                  y: 2,
                                  width: contentView.height - 4,
                                  height: contentView.height - 4)
        
        rightIconView.frame = CGRect(x: contentView.right - rightIconSize - 8,
                                     y: (contentView.height - rightIconSize) / 2.0,
                                     width: rightIconSize,
                                     height: rightIconSize + 5)
        
        if subtileLabel.text != nil {
            titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
            titleLabel.frame = CGRect(x: imageViewBox.right + 5,
                                      y: 5,
                                      width: contentView.width - imageViewBox.width - rightIconSize - 16,
                                      height: titleLabelSize.height)
            
            
            subtileLabel.font = .systemFont(ofSize: 14, weight: .regular)
            subtileLabel.frame = CGRect(x: imageViewBox.right + 5,
                                        y: contentView.bottom - subtileLabel.height - 7,
                                        width: titleLabel.width,
                                        height: subtileLabel.height)
        }
        else {
            titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
            titleLabel.frame = CGRect(x: imageViewBox.right + 5,
                                      y: (contentView.height - titleLabelSize.height)/2.0,
                                      width: contentView.width - imageViewBox.width - 31,
                                      height: titleLabelSize.height )
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = nil
        imageViewBox.image = Utils.defaultImage
        subtileLabel.text = nil
        rightIconView.isHidden = false
    }
    
    public func configure(with data: DefaultSearchResultTableViewCellViewModel?) {
        guard let data = data else {
            return
        }
        titleLabel.text = data.title
        imageViewBox.sd_setImage(with: data.artWorkUrl,placeholderImage: Utils.defaultPlaylistImage, completed: nil)
        if data.subtitle != nil {
            subtileLabel.text = data.subtitle
        }
        if(!data.shouldIndicateOfTrackView) {
            rightIconView.isHidden = true
        }
    }
    
}
