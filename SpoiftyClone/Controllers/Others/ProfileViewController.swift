//
//  ProfileViewController.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 27/03/21.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController, UITableViewDelegate , UITableViewDataSource {
    private let tableView:UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    var profileData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Profile"
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        getProfileInfo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = CGRect(x: 0, y: 0, width: view.width*0.9, height: view.height)
        tableView.center = view.center
    }
    
    // MARK: - Private
    private func getProfileInfo() {
        DispatchQueue.background(background: {
            ApiCaller.shared.getUserProfile(completion: { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let model):
                        self?.populateValueAndUpdateUI(with: model)
                    case .failure(let err):
                        self?.showErrorForProfileFetchFailed(with: err)
                    }
                }
            })
        })
    }
    
    private func populateValueAndUpdateUI(with model:UserProfile){
        profileData.append("DisplayName: \(model.display_name)")
        if let id = model.id{
            profileData.append("id: \(id)")
        }
        if let product = model.product {
            profileData.append("Product: \(product)")
        }
        if let FlwCount = model.followers.total {
            profileData.append("Followers: \(FlwCount)")
        }
        addImageHeaderView(with: model.images.first?.url)
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    private func addImageHeaderView(with urlString:String?){
        guard let urlString = urlString, let url = URL(string: urlString) else {
            print("ProfileViewController: No Image URL found")
            return
        }
        
        let headerView = UIView(frame: CGRect(x:0, y: 0, width: tableView.width, height: view.width/1.5))
        let imageSize: CGFloat = headerView.height/2
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        imageView.center = headerView.center
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageSize/2
        imageView.sd_setImage(with: url, completed: nil)
        
        headerView.addSubview(imageView)
        tableView.tableHeaderView = headerView
    }
    
    private func showErrorForProfileFetchFailed(with err:Error) {
        let alert: UIAlertController = UIAlertController(title: "Something went wrong",
                                                         message: "Profile referesh failed because \(err.localizedDescription)",
                                                         preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {[weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
}

// MARK:- TableView Stuff
extension ProfileViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = profileData[indexPath.row]
        return cell
    }
}
