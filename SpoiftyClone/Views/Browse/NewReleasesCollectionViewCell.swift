//
//  NewReleasesCollectionViewCell.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 23/04/21.
//

import UIKit
import SDWebImage

class NewReleasesCollectionViewCell: UICollectionViewCell {
    static let identifier = "NewReleasesCollectionViewCell"
    
    // MARK: Components
    private let albumCoverImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = Utils.defaultImage
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let albumNameLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0;
        label.font = .systemFont(ofSize: 25, weight: .bold)
        return label
    }()
    
    private let totalCountLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .light)
        return label
    }()
    
    private let artistNameLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.allowsDefaultTighteningForTruncation = true
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    // MARK: init and overrides
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(albumNameLabel)
        contentView.addSubview(totalCountLabel)
        contentView.addSubview(artistNameLabel)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        albumNameLabel.text = nil
        artistNameLabel.text = nil
        totalCountLabel.text = nil
        albumCoverImageView.image = Utils.defaultImage
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        albumNameLabel.sizeToFit()
        artistNameLabel.sizeToFit()
        totalCountLabel.sizeToFit()
        
        let imageSize = contentView.height - 10
        let albumNameSize = albumNameLabel.sizeThatFits(CGSize(width: contentView.width - imageSize - 10, height: min(contentView.height - 10, 80)))
        let artistNameSize = artistNameLabel.sizeThatFits(CGSize(width: contentView.width - imageSize - 10, height: 50))
        albumCoverImageView.frame = CGRect(x: 5,
                                           y: 5,
                                           width: imageSize,
                                           height: imageSize)
        
        albumNameLabel.frame = CGRect(x: albumCoverImageView.right + 5,
                                      y: albumCoverImageView.top,
                                      width: albumNameSize.width,
                                      height: min(80,albumNameSize.height))
        
        artistNameLabel.frame = CGRect(x: albumCoverImageView.right + 5,
                                       y: contentView.height - artistNameSize.height - 5,
                                       width: artistNameSize.width,
                                       height: artistNameSize.height)
        
        totalCountLabel.frame = CGRect(x: contentView.bounds.maxX - totalCountLabel.width - 5,
                                       y: contentView.height - 20,
                                       width: totalCountLabel.width,
                                       height: totalCountLabel.height)
        totalCountLabel.textColor = .systemGreen
    }
    
    func configure(with viewModel:NewReleaseCellViewModel) {
        albumNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        totalCountLabel.text = "Tracks \(viewModel.numberOfTracks)"
        albumCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
    }
}
