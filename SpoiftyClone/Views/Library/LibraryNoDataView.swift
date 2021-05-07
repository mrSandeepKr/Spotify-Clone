//
//  LibraryNoDataView.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 03/05/21.
//

import UIKit

protocol LibraryNoDataViewDelegate : AnyObject {
    func libraryNoDataViewDidTapAction()
}

struct LibraryNoDataViewModel {
    let textLabelMessage: String
    let btnTitle: String
}

class LibraryNoDataView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubview(textLabel)
        addSubview(actionBtn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel.frame = CGRect(x: 0,
                                 y: 0,
                                 width: width,
                                 height: 100)
        
        actionBtn.frame = CGRect(x: width/6,
                                         y: textLabel.bottom,
                                         width: (width/1.5),
                                         height: 30)
        
    }
    
    //MARK:Public
    weak var delegate: LibraryNoDataViewDelegate?
    
    func configureView(with viewData: LibraryNoDataViewModel) {
        textLabel.text = viewData.textLabelMessage
        actionBtn.setTitle(viewData.btnTitle, for: .normal)
    }
    
    //MARK: Elements
    private let textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let actionBtn: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(didTapActionBtn), for: .touchUpInside)
        btn.backgroundColor = .systemGreen
        btn.layer.cornerRadius = 3
        btn.layer.masksToBounds = true
        return btn
    }()
    
    //MARK: Private
    @objc private func didTapActionBtn() {
        delegate?.libraryNoDataViewDidTapAction()
    }
}
