//
//  ApiCaller.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 27/03/21.
//

import Foundation

final class ApiCaller {
    static let shared = ApiCaller()
    
    private init() {}
    
    struct Constants {
        static let baseEndPoint = "https://api.spotify.com/v1"
        static let profilePath = "/me"
        static let newReleasesPath = "/browse/new-releases"
        static let featuredPlaylistPath = "/browse/featured-playlists"
        static let getRecommendedGenrePath = "/recommendations/available-genre-seeds"
        static let getRecommendationsPath = "/recommendations"
        static var getAlbumDetailsPath = "/albums/%@"
        static var getPlaylistDetailsPath = "/playlist/%@"
        static var getAllCategories = "/browse/categories"
        static var getCategoryPlaylistPath = "/browse/categories/%@/playlists"
        static var getCurrentUserPlaylistPath = "/me/playlists"
        static var generatePlaylistPath = "/users/%@/playlists"
        static var addToPlaylistPath = "/playlists/%@/tracks"
        static var removeFromPlaylistPath = "/playlists/%@/tracks"
        static var searchPath = "/search"
        static var meAlbumsPath = "/me/albums"
        static var meAlbumContainsPath = "/me/albums/contains"
        static let newReleasesFetchLimit = 50
        static let getCategoriesFetchLimit = 50
        static let featuredPlaylistFetchLimit = 50
    }
    
    // MARK: Profile
    public func getUserProfile(completion: @escaping ((Result<UserProfile,Error>) -> Void)) {
        createRequest(urlComp: URLComponents(string: Constants.baseEndPoint+Constants.profilePath),
                      type: .GET,
                      params: nil,
                      completion: { req in
                        let task = URLSession.shared.dataTask(with: req) {data, _, error in
                            guard let data = data, error == nil else {
                                completion(.failure(ApiError.failedToGetData))
                                return
                            }
                            
                            do {
                                let result = try JSONDecoder().decode(UserProfile.self, from: data)
                                print("ApiCaller: Profile Fetched Successfully for \(result.display_name)")
                                completion(.success(result))
                            }
                            catch {
                                print("ApiCaller: Profile Fetched Failed with \(error)")
                                completion(.failure(error))
                            }
                        }
                        task.resume()
                      })
    }
    
    // MARK: Browse
    public func getNewRelease(completion: @escaping (Result<NewReleaseResponse,Error>)-> Void) {
        let param = ["limit": String(Constants.newReleasesFetchLimit)]
        
        createRequest(urlComp: URLComponents(string: Constants.baseEndPoint + Constants.newReleasesPath),
                      type: .GET,
                      params: param,
                      completion: {req in
                        let task = URLSession.shared.dataTask(with: req){data, _ , error in
                            guard let data = data, error == nil else {
                                completion(.failure(ApiError.failedToGetData))
                                return
                            }
                            
                            do {
                                let results = try JSONDecoder().decode(NewReleaseResponse.self, from: data)
                                print("ApiCaller: Get New Release Successful")
                                completion(.success(results))
                            }
                            catch {
                                print("ApiCaller: Get New Release request failed with error of \(error)")
                                completion(.failure(error))
                            }
                        }
                        task.resume()
                      })
    }
    
    // MARK: Get Featured Playlist
    public func getFeaturedPlaylists(completion: @escaping (Result<FeaturedPlaylistResponse,Error>)->Void) {
        let param: [String: String] = ["limit":String(Constants.featuredPlaylistFetchLimit)]
        createRequest(urlComp: URLComponents(string: Constants.baseEndPoint + Constants.featuredPlaylistPath),
                      type: .GET,
                      params: param,
                      completion: {req in
                        let task = URLSession.shared.dataTask(with: req, completionHandler: {data ,_ , error in
                            guard let data = data, error == nil else {
                                completion(.failure(ApiError.failedToGetData))
                                return
                            }
                            
                            do {
                                let results = try JSONDecoder().decode(FeaturedPlaylistResponse.self, from: data)
                                print("ApiCaller: Get Featured Playlist Successful")
                                completion(.success(results))
                            }
                            catch{
                                print("ApiCaller: get Featured Playlist failed with \(error)")
                                completion(.failure(error))
                            }
                            
                        })
                        task.resume()
                      })
    }
    
    // MARK: Get Recommended songs bases on 5 random genre
    public func getRecommendations(genreSeed:String ,completion: @escaping (Result<RecommendationResponse,Error>)->Void) {
        let params: [String: String] = ["seed_genres":genreSeed]
        createRequest(urlComp: URLComponents(string: Constants.baseEndPoint + Constants.getRecommendationsPath),
                      type: .GET,
                      params: params,
                      completion: {req in
                        let task = URLSession.shared.dataTask(with: req, completionHandler: {data ,_ , error in
                            guard let data = data, error == nil else {
                                completion(.failure(ApiError.failedToGetData))
                                return
                            }
                            
                            do {
                                let result = try JSONDecoder().decode(RecommendationResponse.self, from: data)
                                print("ApiCaller: get Recommendations - Success")
                                completion(.success(result))
                            }
                            catch{
                                print("ApiCaller: get Recommendations failed with \(error)")
                                completion(.failure(error))
                            }
                            
                        })
                        task.resume()
                      })
    }
    
    // MARK: Get Recommended Genre
    public func getRecommendedGenre(completion: @escaping (Result<RecommendedGenreResponse,Error>)->Void) {
        createRequest(urlComp: URLComponents(string: Constants.baseEndPoint + Constants.getRecommendedGenrePath),
                      type: .GET,
                      params: nil,
                      completion: {req in
                        let task = URLSession.shared.dataTask(with: req, completionHandler: {data ,_ , error in
                            guard let data = data, error == nil else {
                                completion(.failure(ApiError.failedToGetData))
                                return
                            }
                            
                            do {
                                let res = try JSONDecoder().decode(RecommendedGenreResponse.self, from: data)
                                print("ApiCaller: get Recommended Genre - Success")
                                completion(.success(res))
                            }
                            catch{
                                print("ApiCaller: get Recommended Genres - failed with \(error)")
                                completion(.failure(error))
                            }
                            
                        })
                        task.resume()
                      })
    }
    
    // MARK: Get All Categories
    public func getAllCategories(completion: @escaping (Result<[CategoryObject],Error>)->Void) {
        let param = ["limit": String(Constants.getCategoriesFetchLimit)]
        
        createRequest(urlComp: URLComponents(string: Constants.baseEndPoint + Constants.getAllCategories),
                      type: .GET,
                      params: param,
                      completion: {req in
                        let task = URLSession.shared.dataTask(with: req, completionHandler: {data ,_ , error in
                            guard let data = data, error == nil else {
                                completion(.failure(ApiError.failedToGetData))
                                return
                            }
                            
                            do {
                                let res = try JSONDecoder().decode(FetchAllCategoryResponse.self, from: data)
                                let categories = res.categories.items
                                print("ApiCaller: get All Categories- Success")
                                completion(.success(categories))
                            }
                            catch{
                                print("ApiCaller: get All Categories - failed with \(error)")
                                completion(.failure(error))
                            }
                            
                        })
                        task.resume()
                      })
    }
    
    // MARK: Get Playlists of a Category
    public func getPlaylistOfCategory(for categoryId: String, completion: @escaping(Result<[Playlist], Error>) -> Void) {
        let param = ["limit": "10"]
        
        createRequest(urlComp: URLComponents(string: Constants.baseEndPoint + String(format: Constants.getCategoryPlaylistPath, categoryId)),
                      type: .GET,
                      params: param) { req in
            print(req)
            let task = URLSession.shared.dataTask(with: req, completionHandler: {data ,_ , error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(FetchCategoryPlaylistResponse.self, from: data)
                    print("ApiCaller: get Playlists for Category \(categoryId) - Success")
                    completion(.success(result.playlists.items))
                    return
                }
                catch{
                    print("ApiCaller: get Playlist Details - Failed with \(error)")
                    completion(.failure(error))
                }
                
            })
            task.resume()
        }
    }
    
    // MARK: Albums
    public func getAlbumDetails(for album: Album, completion: @escaping(Result<FetchAlbumDetailsResponse, Error>) -> Void) {
        createRequest(urlComp: URLComponents(string: Constants.baseEndPoint + String(format: Constants.getAlbumDetailsPath, album.id)),
                      type: .GET,
                      params: nil) { req in
            let task = URLSession.shared.dataTask(with: req, completionHandler: {data ,_ , error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    print("ApiCaller: get Album Details - Failed with \(ApiError.failedToGetData)")
                    return
                }
                
                do {
                    let res = try JSONDecoder().decode(FetchAlbumDetailsResponse.self, from: data)
                    print("ApiCaller: get Album Details - Success")
                    completion(.success(res))
                }
                catch{
                    print("ApiCaller: get Album Details - Failed with \(error)")
                    completion(.failure(error))
                }
                
            })
            task.resume()
        }
    }
    
    public func modifySavedAlbums(for albums:[Album],isSaving:Bool, completion: @escaping (Result<Bool,Error>)-> Void) {
        let uriString = albums.compactMap({return $0.id}).joined(separator: ",")
        let param = ["ids":uriString]

        createRequest(urlComp: URLComponents(string: Constants.baseEndPoint + Constants.meAlbumsPath),
                      type: isSaving ? .PUT : .DELETE,
                      params: param) { baseReq in
            var req = baseReq
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: req) { _, responseData, err in
                guard let responseData = responseData, err == nil else {
                    if isSaving {
                        print("ApiCaller: Saving Album - Failed with \(String(describing: err))")
                    } else {
                        print("ApiCaller: Removing Album - Failed with \(String(describing: err))")
                    }
                    
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                let statusCode = (responseData as? HTTPURLResponse)?.statusCode
                if statusCode == 200 {
                    if isSaving {
                        print("ApiCaller: Saving Album - Success")
                    } else {
                        print("ApiCaller: Removing Album - Success")
                    }
                    
                    completion(.success(true))
                }
                else {
                    if isSaving {
                        print("ApiCaller: Saving Album - Failed with statusCode \(String(describing: statusCode))")
                    } else {
                        print("ApiCaller: Removing Album - Failed with statusCode \(String(describing: statusCode))")
                    }
                    
                    completion(.success(false))
                }
            }

            task.resume()
        }
    }
    
    public func checkIfAlbumsAreSaved(for albums:[Album], completion: @escaping (Result<[Bool],Error>)-> Void) {
        let uriString = albums.compactMap({return $0.id}).joined(separator: ",")
        let param = ["ids":uriString]
        
        createRequest(urlComp: URLComponents(string: Constants.baseEndPoint + Constants.meAlbumContainsPath),
                      type: .GET,
                      params: param) { req in
            let task = URLSession.shared.dataTask(with: req) { data, _ , err in
                guard let data = data, err == nil else {
                    print("ApiCaller: Check If ALbums are Saved - Failed with \(String(describing: err))")
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                do {
                    let res = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    let boolArr = res as? [Bool]
                    if let boolArr = boolArr {
                        print("ApiCaller: Check if Albums are Saved - Success")
                        completion(.success(boolArr))
                    }
                    else {
                        print("ApiCaller: Check if Albums are Saved - Failed")
                    }
                }
                catch {
                    print("ApiCaller: Check If ALbums are Saved - Failed with \(error))")
                    completion(.failure(error))
                    return
                }
            }
            task.resume()
        }
    }
    
    public func getSavedUserAlbums(completion: @escaping (Result<[Album],Error>) -> Void) {
        let param = ["limit":"50"]
        createRequest(urlComp: URLComponents(string: Constants.baseEndPoint + Constants.meAlbumsPath),
                      type: .GET,
                      params: param) { req in
            let task = URLSession.shared.dataTask(with: req) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    print("ApiCaller: Get User's Saved Albums - Failed with \(ApiError.failedToGetData)")
                    return
                }
                
                do {
                    let res = try JSONDecoder().decode(SavedAlbumRespose.self, from: data)
                    print("ApiCaller: Get User's Saved Albums - Success")
                    completion(.success(res.items.compactMap({
                        var albumObject = $0.album
                        if let images = $0.images {
                            albumObject.images = images
                        }
                        return albumObject
                    })))
                }
                catch{
                    print("ApiCaller: Get User's Saved Albums - Failed with \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: Playlist
    public func getPlaylistDetails(for playlist: Playlist, completion: @escaping(Result<PlaylistDetail, Error>) -> Void) {
        createRequest(urlComp: URLComponents(string: Constants.baseEndPoint +  "/playlists/\(playlist.id)"),
                      type: .GET,
                      params: nil) { req in
            let task = URLSession.shared.dataTask(with: req, completionHandler: {data ,_ , error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let res = try JSONDecoder().decode(PlaylistDetail.self, from: data)
                    print("ApiCaller: get Playlist Details - Success")
                    completion(.success(res))
                }
                catch{
                    print("ApiCaller: get Playlist Details - Failed with \(error)")
                    completion(.failure(error))
                }
                
            })
            task.resume()
        }
    }
    
    public func getCurrentUserPlaylist(completion: @escaping (Result<[Playlist],Error>)-> Void) {
        createRequest(urlComp: URLComponents(string: Constants.baseEndPoint + Constants.getCurrentUserPlaylistPath),
                      type: .GET,
                      params: nil) { req in
            let task = URLSession.shared.dataTask(with: req) { data, _, error in
                guard let data = data, error == nil else {
                    print("ApiCaller: Get Current User Playlist - Failed")
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let res = try JSONDecoder().decode(GetCurrentUserPlaylistResponse.self, from: data)
                    print("ApiCaller: Get Current User Playlist - Success")
                    completion(.success(res.items))
                }
                catch {
                    print("ApiCaller: Get Current User Playlist - Failed with \(error)")
                }
            }
            task.resume()
        }
    }
    
    public func generatePlaylist(with playlistName:String,desc: String, completion: @escaping (Result<Bool,Error>) -> Void) {
        var httpBody = ["name":playlistName]
        if !desc.isEmpty {
            httpBody["description"] = desc
        }
        
        createRequest(urlComp: URLComponents(string: Constants.baseEndPoint + String(format: Constants.generatePlaylistPath, Utils.getUserId())),
                      type: .POST,
                      httpBody: httpBody) { req in
            let task = URLSession.shared.dataTask(with: req) { data, _, error in
                guard let data = data, error == nil else {
                    print("ApiCaller: Playlist Creation - Failed with \(String(describing: error))")
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let res = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let response = res as? [String : Any?], let id = response["id"] as? String, !id.isEmpty {
                        print("ApiCaller: Playlist Creation - Success")
                        completion(.success(true))
                        return
                    }
                    print("ApiCaller: Playlist Creation: Failed with Result \(res)")
                    completion(.success(false))
                }
                catch {
                    print("ApiCaller: Playlist Creation - Failed with \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func addTracksToPlaylist(with tracks: [AudioTrack],
                                    to playlist: Playlist,
                                    completion: @escaping (Result<Bool,Error>) -> Void) {
        let uriList = tracks.compactMap({return $0.uri}).joined(separator: ",")
        let param = ["uris":uriList]
        
        createRequest(urlComp: URLComponents(string: Constants.baseEndPoint + String(format:  Constants.addToPlaylistPath, playlist.id)),
                      type: .POST,
                      params: param) { baseReq in
            var req = baseReq
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: req) { data, _ , error in
                guard let data = data, error == nil else {
                    print("ApiCaller: Add to Playlist - Failed with \(String(describing: error))")
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let res = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let response = res as? [String : Any?], let snapshot_id = response["snapshot_id"] as? String, !snapshot_id.isEmpty {
                        print("ApiCaller: Add to Playlist: Success")
                        completion(.success(true))
                        return
                    }
                    print("ApiCaller: Add to Playlist: Failed with Result \(res)")
                    completion(.success(false))
                }
                catch {
                    print("ApiCaller: Add to Playlist: Failed with \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func removeTrackFromPlaylist(with tracks: [AudioTrack],
                                        from playlist: Playlist,
                                        completion: @escaping (Result<Bool,Error>) -> Void) {
        let trackList = tracks.compactMap({return ["uri":$0.uri]})
        let httpBody = [ "tracks": trackList]
        createRequest(urlComp: URLComponents(string: Constants.baseEndPoint + String(format:  Constants.removeFromPlaylistPath, playlist.id)),
                      type: .DELETE,
                      httpBody: httpBody) { baseReq in
            var req = baseReq
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: req) { data, _ , error in
                guard let data = data, error == nil else {
                    print("ApiCaller: Remove from Playlist - Failed with \(String(describing: error))")
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let res = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let response = res as? [String : Any?], let snapshot_id = response["snapshot_id"] as? String, !snapshot_id.isEmpty {
                        print("ApiCaller: Remove from Playlist: Success")
                        completion(.success(true))
                        return
                    }
                    print("ApiCaller: Remove from Playlist: Failed with Result \(res)")
                    completion(.success(false))
                }
                catch {
                    print("ApiCaller: Remove from Playlist: Failed with \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    //MARK: Get search results for a search term
    public func getSearchResults(for searchTerm:String, completion: @escaping (Result<[SearchResultDataObject], Error>) -> Void){
        let param = ["limit":"8",
                     "type": "album,artist,playlist,track",
                     "q":searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                     ]

        createRequest(urlComp: URLComponents(string: Constants.baseEndPoint + Constants.searchPath),
                      type: .GET,
                      params: param) { req in
            let task = URLSession.shared.dataTask(with: req) { (data, _, error) in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    print("ApiCaller: Search Call Failed")
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(FetchSearchResultsResponse.self, from: data)
                    print("ApiCaller: get Search Results - Success")
                    var searchResultData = [SearchResultDataObject]()
                    if let album = result.albums {
                        searchResultData.append(contentsOf: (album.items.compactMap({SearchResultDataObject.albums(model: $0)})))
                    }
                    if let tracks = result.tracks {
                        searchResultData.append(contentsOf: (tracks.items.compactMap({SearchResultDataObject.tracks(model: $0)})))
                    }
                    if let playlists = result.playlists {
                        searchResultData.append(contentsOf: (playlists.items.compactMap({SearchResultDataObject.playlists(model: $0)})))
                    }
                    if let artists = result.artists {
                        searchResultData.append(contentsOf: (artists.items.compactMap({SearchResultDataObject.artists(model: $0)})))
                    }
                    
                    completion(.success(searchResultData))
                    return
                }
                catch {
                    print("ApiCaller: getSearch Results - Failed with \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
            }
            task.resume()
        }
    }
}

// MARK: Support and Utils
extension ApiCaller {
    enum HttpMethod: String {
        case GET
        case POST
        case DELETE
        case PUT
    }
    
    enum ApiError: Error {
        case failedToGetData
    }
    
    private func createRequest(urlComp: URLComponents?,
                               type: HttpMethod,
                               params: [String:String?]? = nil,
                               httpBody: [String: Any]? = nil,
                               completion: @escaping (URLRequest)->Void) {
        guard var resolvedURLComp = urlComp else {
            return
        }
        
        if let params = params {
            var paramAsCmponents = [URLQueryItem]()
            params.forEach{(key, value) in
                paramAsCmponents.append(URLQueryItem(name: key, value: value))
            }
            resolvedURLComp.queryItems = paramAsCmponents
        }
        
        AuthManager.shared.getValidToken(completion: {token in
            var request = URLRequest(url: resolvedURLComp.url!)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            
            if let json = httpBody {
                request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            }
            
            completion(request)
        })
    }
}
