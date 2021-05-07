//
//  WelcomeViewController.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 27/03/21.
//

import UIKit

class WelcomeViewController: UIViewController {

    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In", for: .normal)
        button.setTitleColor(.link, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.black.cgColor
        return button
    }()
    
    private let backGroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "welcomeBack")
        return imageView
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.1
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Spotify Clone"
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let descLabel: UILabel = {
        let label = UILabel()
        label.text = "This is just a fun project guys, was a great learning experience"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.numberOfLines = 0
        label.textColor =  .systemGreen
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGreen
        view.addSubview(backGroundImageView)
        view.addSubview(overlayView)
        view.addSubview(titleLabel)
        view.addSubview(descLabel)
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let titleSize = titleLabel.sizeThatFits(CGSize(width: 400, height: 100))
        titleLabel.frame = CGRect(x: 20, y: 90, width: titleSize.width, height: titleSize.height)
        
        backGroundImageView.frame = view.bounds
        overlayView.frame = view.bounds
        signInButton.frame = CGRect(x: 40, y: (view.height * 0.9) -  50, width: view.width - 80, height: 50)
        descLabel.frame = CGRect(x: 20, y: signInButton.top - 55, width: view.width - 40, height: 50)
    }
    
    @objc func didTapSignIn() {
        let vc = AuthViewController()
        
        vc.completionHandler = { [weak self] success in
            // we set the value of completion handle so AuthViewController should trigger YES once SignIn is complete.
            DispatchQueue.main.async {
                self?.handleSignIn(success: success)
            }
        }
        
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func handleSignIn(success: Bool) {
        guard success else {
            let alert = UIAlertController(title: "Try Again", message: "Something went wrong during the Sign In", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ohh No", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let mainTabBarViewController = TabBarViewController()
        mainTabBarViewController.modalPresentationStyle = .fullScreen
        present(mainTabBarViewController, animated: true, completion: nil)
    }
}
