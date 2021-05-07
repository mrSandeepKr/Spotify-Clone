//
//  SectionTitleCollectionReusableView.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 25/04/21.
//

import UIKit

class SectionTitleCollectionReusableView: UICollectionReusableView {
    static let identifier = "SectionTitleCollectionReusableView"
    
    private let sectionTitleLabel : UILabel =  {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = .systemGray2
        label.textAlignment = .left
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(sectionTitleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sectionTitleLabel.sizeToFit()
        sectionTitleLabel.frame = CGRect(x: 5, y: 5, width: frame.width - 10, height: frame.height - 10)
    }
    
    func configureHeader(viewModel: SectionTitleViewModel) {
        sectionTitleLabel.text = viewModel.sectionTitle
    }
}
