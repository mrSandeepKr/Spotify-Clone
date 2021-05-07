//
//  AuthViewController.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 27/03/21.
//

import UIKit
import WebKit

class AuthViewController: UIViewController, WKNavigationDelegate {
    
    private let webView : WKWebView = {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = prefs
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        guard let url = AuthManager.shared.signInUrl else {
            print("Sign in url is nil")
            return webView
        }
        print("SignIn Url : \(url.absoluteString)")
        webView.load(URLRequest(url: url))
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Sign In"
        view.backgroundColor = .systemBackground
        webView.navigationDelegate = self
        view.addSubview(webView)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }
    
    public var completionHandler: ((Bool)-> Void)?
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else {
            return
        }

        guard let code = AuthManager.shared.getCodeFromUrl(url: url) else {
            return
        }
        print("Suceessful Sign In and Code retrieval from redirect URL")
        
        webView.isHidden = true //hide the redirect page
        AuthManager.shared.exchangeTokenFromCode(code: code){ success  in
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
                self.completionHandler?(success)
            }
        }
    }
}
