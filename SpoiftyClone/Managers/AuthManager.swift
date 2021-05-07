//
//  AuthManager.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 27/03/21.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    //To handle Token request while token refresh
    private var isRefreshingToken = false
    private var refreshBlocks = [((String)-> Void)]()
    
    public init() {}
    
    /// Returns if the user is signed in based on - if the access Token is available in cache
    var isSignedIn: Bool {
        return accessToken != nil
    }
    
    /// This function gets the Token once we have a successful redirection post user SignIn
    public func exchangeTokenFromCode(code:String, completion:@escaping ((Bool) -> Void)){
        guard let url = URL(string: Constants.tokenApiURL) else {
            return
        }

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURL)
        ]
        
        httpRequestForTokenFetch(components: components,url: url,isTokenRefresh: false, completion: completion)
    }
    
    /// Returns the valid Token While handling scenarios of expired Token, refreshing in progress and valid Token Being available in cache.
    public func getValidToken(completion: @escaping ((String)-> Void)){
        if isRefreshingToken {
            // if we are refreshing the token just keep saving the callers
            refreshBlocks.append(completion)
            return
        }
        
        if shouldRefreshToken {
            refreshIfNeeded(completion: {[weak self] success in
                if let accessToken = self?.accessToken , success{
                    completion(accessToken)
                }
            })
        }
        else if let token = accessToken {
            completion(token)
        }
    }
    
    /// Refreshs The Token If Needed, returns success if the token is refreshed else false.
    public func refreshIfNeeded(completion: @escaping (Bool) -> Void){
        guard shouldRefreshToken else {
            // If refresh is not needed then don't do it, return by saying refresh was successful.
            completion(true)
            return
        }
        
        guard let refreshToken = self.refreshToken,let url: URL = URL(string: Constants.tokenApiURL) else {
            // Clear user defaults.
            print("Sign Out user")
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            return
        }
        
        //begin refresh process
        isRefreshingToken = true
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        
        httpRequestForTokenFetch(components: components,url: url,isTokenRefresh: true,completion: {[weak self] success in
            if success {
                self?.isRefreshingToken = false;
                self?.refreshBlocks.forEach{ $0((self?.accessToken)!)}
                self?.refreshBlocks.removeAll()
            }
            
            completion(success)
        })
    }
    
    private func httpRequestForTokenFetch(components: URLComponents, url: URL,isTokenRefresh: Bool, completion: @escaping ((Bool) -> Void)) -> Void {
        var request : URLRequest = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        guard let base64String = (Constants.clientID+":"+Constants.clientSecret).data(using: .utf8)?.base64EncodedString() else {
            print("Uable to get base64 encoded string")
            return
        }
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        if(isTokenRefresh){
            print("Beginning Token refresh")
        } else {
            print("Fetching Token First time")
        }
        
        let task = URLSession.shared.dataTask(with: request){ [weak self] data , _  ,err  in
            guard let data = data, err == nil else {
                print("Error while token fetch \(String(describing: err))")
                completion(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cacheToken(result: result)
                
                if(isTokenRefresh){
                    print("Successful Token refresh")
                }else{
                    print("Successful first Token Fetch")
                }
                
                completion(true)
            }
            catch {
                print("Token Extraction Failed with Error \(String(describing: err))")
                completion(false)
            }
        }
        
        task.resume()
    }
}

//Mark: Supplies the required Variables
extension AuthManager {
    struct Constants {
        static let clientID = "CLIENT ID"
        static let clientSecret = "CLIENT SECRET"
        static let tokenApiURL = "https://accounts.spotify.com/api/token"
        static let redirectURL = "https://www.iosacademy.io"
        static let scopeList = ["user-read-private","user-read-email","playlist-modify-public","playlist-read-private","playlist-modify-private","user-follow-read","user-library-modify","user-library-read"]
    }
    
    var signInUrl : URL? {
        let base = "https://accounts.spotify.com/authorize"
        let scopes = getScope
        let param = "?response_type=code&client_id=\(Constants.clientID)&redirect_uri=\(Constants.redirectURL)&scope=\(scopes)&show_dialog=TRUE"
        let url: String = "\(base)\(param)"
        
        return URL(string: url)
    }
    
    private var getScope: String {
        var allScope = ""

        Constants.scopeList.forEach { scope in
            allScope = allScope + "%20"+scope
        }
        
        return allScope
    }
}

//Mark: Utilities to Support Authorization
extension AuthManager {
    public func getCodeFromUrl(url : URL) -> String? {
        let component = URLComponents(string: url.absoluteString)
        guard let val = component?.queryItems?.first(where: {$0.name == "code"})?.value else {
            return nil
        }
        return val
    }
    
    private func cacheToken(result: AuthResponse) -> Void {
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        
        if let refreshToken = result.refresh_token{
            UserDefaults.standard.setValue(refreshToken, forKey: "refresh_token")
        }
        
        let timeIntervalForExpiry = TimeInterval(result.expires_in)
        UserDefaults.standard.setValue(Date().addingTimeInterval(timeIntervalForExpiry) ,forKey: "expiration_date")
    }
    
    private var shouldRefreshToken: Bool {
        guard let expirationDate = self.tokenExpirationDate else {
            return false;
        }
        let currentDate = Date()
        let buffer = TimeInterval(300) // 5mins
        return currentDate.addingTimeInterval(buffer) >= expirationDate
    }
    
    public func signOut(completion: (Bool) -> Void) {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        if self.isSignedIn {
            completion(false)
        }else {
            completion(true)
        }
    }
}

//Mark: Returna the cached data
extension AuthManager {
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expiration_date") as? Date
    }
}
