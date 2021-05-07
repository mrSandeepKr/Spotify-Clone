//
//  SettingsViewController.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 27/03/21.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var settingsList: [Section] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self

        populateSectionData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
}

// MARK: - TableViewDelegate
extension SettingsViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.settingsList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingsList[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.settingsList[indexPath.section].options[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.settingsList[indexPath.section].options[indexPath.row].handle()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.settingsList[section].title
    }
}

// MARK: - Settings Model
extension SettingsViewController {
    private func populateSectionData() {
        self.settingsList.append(Section(title: "Profile", options: [Option(title: "View your Profile", handle: { [weak self] in
            DispatchQueue.main.async {
                self?.didTapViewProfile()
            }
        })]))
        
        self.settingsList.append(Section(title: "Settings", options: [Option(title: "Sign Out", handle:{[weak self] in
            self?.didTapSignOut()
        })]))
    }
    
    @objc func didTapViewProfile() {
        let vc = ProfileViewController()
        vc.title = "Profile"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapSignOut() {
        AuthManager.shared.signOut {[weak self] isSignedOut in
            if isSignedOut {
                DispatchQueue.main.async {
                    let nav = UINavigationController(rootViewController: WelcomeViewController())
                    nav.navigationBar.prefersLargeTitles = true
                    nav.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
                    nav.modalPresentationStyle = .fullScreen
                    self?.present(nav, animated: true) {
                        self?.navigationController?.popToRootViewController(animated: false)
                    }
                }
            }
        }
    }
}
