//
//  LibraryPlaylistViewController.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 02/05/21.
//

import UIKit

enum LibPlaylistEntryPoint {
    case addTrackToPlaylist
    case libraryView
}

class LibraryPlaylistViewController: UIViewController {
    var entryPoint : LibPlaylistEntryPoint
    var trackToAdd : AudioTrack? = nil
    
    init(entryPoint: LibPlaylistEntryPoint, track: AudioTrack? = nil) {
        self.entryPoint = entryPoint
        self.trackToAdd = track
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNoPlayListFoundView()
        configureTableView()
        fetchAllPlaylistData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = CGRect(x: 0, y: 10, width: view.width, height: view.height - view.safeAreaInsets.bottom - 10)
        noPlaylistfoundView.frame = CGRect(x: 0, y: 0, width: view.width/2, height: 300)
        noPlaylistfoundView.center = view.center
    }
    
    //MARK:Elements
    private var playlists = [Playlist]()
    private let noPlaylistfoundView = LibraryNoDataView()
    private let tableView : UITableView = {
        let tableView  = UITableView()
        tableView.register(DefaultSearchResultTableViewCell.self, forCellReuseIdentifier: DefaultSearchResultTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    //MARK: Private
    private func configureNoPlayListFoundView() {
        view.addSubview(noPlaylistfoundView)
        noPlaylistfoundView.delegate = self
        noPlaylistfoundView.isHidden = true
        noPlaylistfoundView.configureView(with:
            LibraryNoDataViewModel(
                textLabelMessage: "No playlist found you could try creating one",
                btnTitle: "Create")
        )
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func updateUIIfNeeded() {
        if(playlists.count > 0) {
            noPlaylistfoundView.isHidden = true
            tableView.reloadData()
            tableView.isHidden = false
        } else {
            noPlaylistfoundView.isHidden = false
            tableView.isHidden = true
        }
    }
}
// MARK: TableView Delegate
extension LibraryPlaylistViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DefaultSearchResultTableViewCell.identifier) as? DefaultSearchResultTableViewCell
        else  {
            return UITableViewCell()
        }
        let info = self.playlists[indexPath.row]
        cell.configure(with: DefaultSearchResultTableViewCellViewModel(title: info.name,
                                                                       artWorkUrl: URL(string: info.images?.first?.url ?? ""),
                                                                       subtitle:  info.description,
                                                                       shouldIndicateOfTrackView: entryPoint != .addTrackToPlaylist))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if entryPoint == .addTrackToPlaylist {
            addTrackToPlaylist(for: indexPath)
            return
        }
        
        //Default action is to present the list of tracks under that playlist
        let vc = PlaylistViewController(with: playlists[indexPath.row])
        vc.setUpWithLargeTitleDisplayModerNever()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func addTrackToPlaylist(for indexPath: IndexPath) {
        ApiCaller.shared.addTracksToPlaylist(with: [trackToAdd!],
                                             to: playlists[indexPath.row]) { res in
            return
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK: ToggleView Delegate
extension LibraryPlaylistViewController: LibraryNoDataViewDelegate {
    func libraryNoDataViewDidTapAction() {
        self.showCreatePlaylistAlert()
    }
    
    public func showCreatePlaylistAlert() {
        let alert = UIAlertController(title: "New Playlist", message: "Enter the name of your new playlist", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Enter the name..."
            textField.clearsOnBeginEditing = true
        }
        alert.addTextField { textField in
            textField.placeholder = "Description..."
            textField.clearsOnBeginEditing = true
        }
        
        alert.addAction(UIAlertAction(title: "Create",
                                      style: .default,
                                      handler: { [weak self] _ in
                                        guard let textField = alert.textFields?.first,
                                              let playlistName = textField.text,
                                              !playlistName.trimmingCharacters(in: .whitespaces).isEmpty
                                        else {
                                            return
                                        }
                                        var description = ""
                                        if let textFields = alert.textFields,
                                           textFields.count >= 2,
                                           let desc = textFields[1].text,
                                           !desc.trimmingCharacters(in: .whitespaces).isEmpty {
                                            description = desc
                                        }
                                        
                                        ApiCaller.shared.generatePlaylist(with: playlistName, desc: description) { res in
                                            switch res {
                                            case .success(let created):
                                                if(created) {
                                                    DispatchQueue.main.async {
                                                        self?.fetchAllPlaylistData()
                                                        self?.updateUIIfNeeded()
                                                    }
                                                }
                                                break
                                            default:
                                                break
                                            }
                                        }
                                      }
                                )
        )
        alert.addAction(UIAlertAction(title: "Cancel" , style: .destructive, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: DataLayer
extension LibraryPlaylistViewController {
    private func fetchAllPlaylistData() {
        ApiCaller.shared.getCurrentUserPlaylist {[weak self] res in
            switch res {
            case .success(let model):
                DispatchQueue.main.async {
                    if self?.entryPoint == .addTrackToPlaylist {
                        self?.playlists = model.filter({ return $0.owner.id == Utils.getUserId()})
                    }else {
                        self?.playlists = model
                    }
                    self?.updateUIIfNeeded()
                }
                break
            default:
                break
            }
        }
    }
}
