//
//  PlayersControlView.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 30/04/21.
//

import Foundation
import UIKit

protocol PlayerControlViewDelegate : AnyObject {
    func playerControlViewDidTapPlayPause(_ playControlView: PlayerControlView)
    func playerControlViewDidTapNextButton(_ playControlView: PlayerControlView)
    func playerControlViewDidTapPrevButton(_ playControlView: PlayerControlView)
    func playerControlViewDidChangeVolume(with value: Float)
}

final class PlayerControlView : UIView {
    weak var delegate : PlayerControlViewDelegate?

    // MARK: Private
    private let volSlider : UISlider = {
        let volSlider = UISlider()
        volSlider.value = 0.5
        return volSlider
    }()
    
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let subtitleLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let prevButton : UIButton = {
        let btn = UIButton()
        btn.tintColor = .label
        let image = UIImage(systemName: "backward.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        btn.setImage(image, for: .normal)
        return btn
    }()
    
    private let nextButton : UIButton = {
        let btn = UIButton()
        btn.tintColor = .label
        let image = UIImage(systemName: "forward.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        btn.setImage(image, for: .normal)
        return btn
    }()
    
    private let playPauseButton : UIButton = {
        let btn = UIButton()
        btn.tintColor = .label
        let image = Utils.pauseImage
        btn.setImage(image, for: .normal)
        return btn
    }()
    
    // MARK: Public
    public func configureView(title: String, subTile: String) {
        titleLabel.text = title
        subtitleLabel.text = subTile
    }
    
    public func updatePlayPauseButton(for isPlaying:Bool){
        if isPlaying {
            playPauseButton.setImage(Utils.pauseImage, for: .normal)
        }else {
            playPauseButton.setImage(Utils.playImage, for: .normal)
        }
    }
    
    // MARK: LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
        setUpButtonActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.sizeToFit()
        
        let titleSize = titleLabel.sizeThatFits(CGSize(width: width - 10, height: titleLabel.height))
        let btnSize = width / 3.5
        
        titleLabel.frame = CGRect(x: 5, y: 5, width: width - 10, height: titleSize.height)
        subtitleLabel.frame = CGRect(x: 3, y: titleLabel.bottom, width: width - 20, height: 130)
        subtitleLabel.textAlignment = .left
        volSlider.frame = CGRect(x: 10, y: subtitleLabel.bottom + 5, width: width - 20, height: 20)
        
        prevButton.frame = CGRect(x: (width - (3.0 * btnSize)) / 2.0,
                                  y: height  - btnSize - 10,
                                  width: btnSize,
                                  height: btnSize)
        playPauseButton.frame = CGRect(x: prevButton.right,
                                       y: height - btnSize - 10,
                                       width: btnSize,
                                       height: btnSize)
        nextButton.frame = CGRect(x: playPauseButton.right,
                                  y: height - btnSize - 10,
                                  width: btnSize,
                                  height: btnSize)
    }
    
    // MARK: Private
    private func setUpViews() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(volSlider)
        addSubview(prevButton)
        addSubview(nextButton)
        addSubview(playPauseButton)
        clipsToBounds = true
        backgroundColor = .clear
    }
    
    private func setUpButtonActions() {
        prevButton.addTarget(self, action: #selector(prevButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        volSlider.addTarget(self, action: #selector(volSliderValueDidChange), for:.valueChanged)
    }
    
    @objc private func prevButtonTapped() {
        delegate?.playerControlViewDidTapPrevButton(self)
    }
    
    @objc private func nextButtonTapped() {
        delegate?.playerControlViewDidTapNextButton(self)
    }
    
    @objc private func playPauseButtonTapped() {
        delegate?.playerControlViewDidTapPlayPause(self)
    }
    
    @objc private func volSliderValueDidChange(_ slider: UISlider){
        delegate?.playerControlViewDidChangeVolume(with: slider.value)
    }
}
