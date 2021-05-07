//
//  FeaturedPlaylistCollectionViewCell.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 23/04/21.
//

import UIKit
import SDWebImage

class FeaturedPlaylistCollectionViewCell: UICollectionViewCell {
    static let identifier = "FeaturedPlaylistCollectionViewCell"
    
    //MARK: Components
    private let playlistImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = Utils.defaultImage
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 2
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let playlistNameLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 2;
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.font = label.font.withWeight(.bold)
        return label
    }()
    
    // MARK: init and override
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(playlistImageView)
        contentView.addSubview(playlistNameLabel)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playlistImageView.image = Utils.defaultImage
        playlistNameLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playlistImageView.frame = CGRect(x: 1.0 * (contentView.center.x / 4.0),
                                         y: 10,
                                         width: 3.0 * (contentView.height/4.0),
                                         height:  3.0 * (contentView.height/4.0))
        
        let paylistNameLabelSize = playlistNameLabel.sizeThatFits(CGSize(width: contentView.width - 4, height: contentView.height - 6 - playlistImageView.height))
        playlistNameLabel.frame = CGRect(x: 2,
                                         y: playlistImageView.bounds.maxY + ((contentView.height - playlistImageView.height + 10 - paylistNameLabelSize.height) / 2.0),
                                         width: contentView.width,
                                         height: paylistNameLabelSize.height)
    }
    
    func configure(with viewModel:FeaturedPlaylistCellViewModel) {
        playlistNameLabel.text = viewModel.name
        playlistImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
    }
}
