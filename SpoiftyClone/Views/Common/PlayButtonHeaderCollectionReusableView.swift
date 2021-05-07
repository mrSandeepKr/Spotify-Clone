//
//  PlaylistHeaderCollectionReusableView.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 25/04/21.
//

import UIKit
import SDWebImage

protocol PlayButtonHeaderCollectionReusableViewDelegate : AnyObject {
    func DidTapPlayAllInHeader()
}

final class PlayButtonHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "PlayButtonHeaderCollectionReusableView"
    weak var delegate : PlayButtonHeaderCollectionReusableViewDelegate?
    
    // MARK: Components
    private let playlistNameLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let descriptionLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let ownerLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemGreen
        return label
    }()
    
    private let playlistImageCover: UIImageView  = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 3
        imageView.image = Utils.defaultImage
        return imageView
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.backgroundColor = .systemGreen
        button.tintColor = .white
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 29
        return button
    }()
    
    //MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(playlistImageCover)
        addSubview(playlistNameLabel)
        addSubview(descriptionLabel)
        addSubview(ownerLabel)
        addSubview(playButton)
        playButton.addTarget(self, action: #selector(didTapPlayAllButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playlistNameLabel.sizeToFit()
        
        ownerLabel.sizeToFit()
        
        let imageSize = frame.width / 1.55
        let descLabelSize = descriptionLabel.sizeThatFits(CGSize(width: frame.width * 0.8, height: 50))
        
        playlistImageCover.frame = CGRect(x: (frame.width - imageSize) / 2.0,
                                          y: 20,
                                          width: imageSize,
                                          height: imageSize)
        playlistNameLabel.frame = CGRect(x: 10,
                                         y: playlistImageCover.frame.maxY + 15,
                                         width: frame.width * 0.95,
                                         height: playlistNameLabel.height)
        
        descriptionLabel.frame = CGRect(x: 10,
                                        y: playlistNameLabel.bottom,
                                        width: descLabelSize.width,
                                        height: descLabelSize.height)
        
        ownerLabel.frame = CGRect(x: 10,
                                  y: frame.height - ownerLabel.height,
                                  width: ownerLabel.width,
                                  height: ownerLabel.height)
        
        playButton.frame = CGRect(x: frame.width - 75,
                                  y: frame.height - 75,
                                  width: 58,
                                  height: 58)
    }
    
    func configureView(viewModel : PlayButtonHeaderViewModel) {
        
        playlistImageCover.sd_setImage(with: viewModel.artworkURL,
                                       placeholderImage: viewModel.placeholderImage,
                                       completed: nil)
        descriptionLabel.text = viewModel.desc
        playlistNameLabel.text = viewModel.name
        ownerLabel.text = "Owner: \(viewModel.owner)"
    }
}

extension PlayButtonHeaderCollectionReusableView {
    @objc func didTapPlayAllButton() {
        delegate?.DidTapPlayAllInHeader()
    }
}
