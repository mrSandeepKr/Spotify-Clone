//
//  RecommendedTracksCollectionViewCell.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 23/04/21.
//

import UIKit

class AudioTracksCollectionViewCell: UICollectionViewCell {
    static let identifier = "AudioTracksCollectionViewCell"
    
    // MARK: Components
    
    private let trackImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = Utils.defaultImage
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let trackNameLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let artistNameLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    // MARK: init and overrides
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(trackImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackNameLabel.text = nil
        artistNameLabel.text = nil
        trackImageView.image = Utils.defaultImage
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        trackNameLabel.sizeToFit()
        trackImageView.sizeToFit()
        artistNameLabel.sizeToFit()
        
        let imageSize = contentView.height - 6
        let artistNameSize = artistNameLabel.sizeThatFits(CGSize(width: contentView.width - imageSize - 10, height: artistNameLabel.height))
        
        trackImageView.frame = CGRect(x: 3,
                                      y: 3,
                                      width: imageSize,
                                      height: imageSize)
        
        trackNameLabel.frame = CGRect(x: trackImageView.right + 5,
                                      y: trackImageView.top,
                                      width: contentView.width - trackImageView.width - 10,
                                      height: contentView.height - artistNameSize.height - 5)
        
        artistNameLabel.frame = CGRect(x: contentView.right - artistNameSize.width - 5,
                                       y: contentView.height - 5 - artistNameSize.height,
                                       width: artistNameSize.width,
                                       height: artistNameSize.height)
    }
    
    func configure(with viewModel:TracksCellViewModel) {
        trackImageView.sd_setImage(with: viewModel.artworkURL,placeholderImage: Utils.defaulTrackImage, completed: nil)
        artistNameLabel.text = viewModel.artistName
        trackNameLabel.text = viewModel.name
    }
}
