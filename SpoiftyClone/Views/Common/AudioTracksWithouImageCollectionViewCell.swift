//
//  AudioTrackWithouImageCollectionViewCell.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 26/04/21.
//

import UIKit

class AudioTracksWithouImageCollectionViewCell: UICollectionViewCell {
    static let identifier = "AudioTracksWithouImageCollectionViewCell"
    
    // MARK: Components

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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        trackNameLabel.sizeToFit()
        artistNameLabel.sizeToFit()
        
        let artistNameSize = artistNameLabel.sizeThatFits(CGSize(width: contentView.width - contentView.height - 16, height: artistNameLabel.height))
        
        
        trackNameLabel.frame = CGRect(x: 5,
                                      y: 3,
                                      width: contentView.width - 10,
                                      height: contentView.height - artistNameSize.height - 5)
        
        artistNameLabel.frame = CGRect(x: contentView.right - artistNameSize.width - 5,
                                       y: contentView.height - 5 - artistNameSize.height,
                                       width: artistNameSize.width,
                                       height: artistNameSize.height)
    }
    
    func configure(with viewModel:TracksCellViewModel) {
        artistNameLabel.text = viewModel.artistName
        trackNameLabel.text = viewModel.name
    }
}
