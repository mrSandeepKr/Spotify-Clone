//
//  ArtistViewController.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 29/04/21.
//

import UIKit
import SDWebImage

class ArtistViewController : UIViewController {
    private var artist : Artist?
    
    private let artistImageView : UIImageView  = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = Utils.defaultImage
        return imageView
    }()
    
    private let artistNameLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = .label
        
        return label
    }()
    
    private let followerLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .systemGreen
        return label
    }()
    
    private let lineView: UIView = {
        let line = UIView()
        line.layer.borderWidth = 1
        line.layer.borderColor = UIColor.label.cgColor;
        return line
    }()
    
    // MARK: life Cycle
    init(with info: Artist) {
        self.artist = info
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(artistImageView)
        view.addSubview(artistNameLabel)
        view.addSubview(followerLabel)
        view.addSubview(lineView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        artistImageView.sizeToFit()
        artistNameLabel.sizeToFit()
        followerLabel.sizeToFit()
        
        let imageSize = CGFloat(250.0)
        artistImageView.layer.cornerRadius = imageSize / 2.0
        
        artistImageView.frame = CGRect(x: (view.width - imageSize ) / 2.0,
                                       y: 0.2 * view.height,
                                       width: imageSize,
                                       height: imageSize)
        if let url =  URL(string : self.artist?.images?.first?.url ?? "") {
            artistImageView.sd_setImage(with:url, completed: nil)
        }
        
        artistNameLabel.text = artist?.name
        let artistNameSize = artistNameLabel.sizeThatFits(CGSize(width: view.width - 30, height: artistNameLabel.height))
        artistNameLabel.frame = CGRect(x: (view.width - artistNameSize.width) / 2.0,
                                       y: artistImageView.bottom + 40,
                                       width: artistNameSize.width,
                                       height: artistNameSize.height)
        
        if let followerCount = artist?.followers?.total {
            lineView.frame = CGRect(x: artistNameLabel.left,
                                    y: artistNameLabel.bottom + 3,
                                    width: artistNameLabel.width,
                                    height: 3.0)
            
            followerLabel.text = "(Follower: \(followerCount))"
            let followerNameSize = followerLabel.sizeThatFits(CGSize(width: view.width - 30, height: followerLabel.height))
            
            followerLabel.frame = CGRect(x: (view.width - followerNameSize.width) / 2.0,
                                         y: artistNameLabel.bottom + 20,
                                         width: followerNameSize.width,
                                         height: followerNameSize.height)
        }
    }
}
