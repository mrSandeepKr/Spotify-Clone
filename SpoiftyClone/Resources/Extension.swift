//
//  Extension.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 11/04/21.
//

import Foundation
import UIKit

extension UIView {
    var width : CGFloat {
        return frame.size.width
    }
    
    var height : CGFloat {
        return frame.size.height
    }
    
    var left : CGFloat {
        return frame.origin.x
    }
    
    var right : CGFloat {
        return left + width
    }
    
    var top : CGFloat {
        return frame.origin.y
    }
    
    var bottom : CGFloat {
        return  top + height
    }
    
    @objc class func withAutoLayout() -> Self {
        let view = self.init()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

extension DispatchQueue {
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
}

extension UIFont {
  func withWeight(_ weight: UIFont.Weight) -> UIFont {
    let newDescriptor = fontDescriptor.addingAttributes([.traits: [
      UIFontDescriptor.TraitKey.weight: weight]
    ])
    return UIFont(descriptor: newDescriptor, size: pointSize)
  }
}

extension UILabel {
    var numberOfVisibleLines: Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
        let textHeight = sizeThatFits(maxSize).height
        let lineHeight = font.lineHeight
        return Int(ceil(textHeight / lineHeight))
    }
}

extension DateFormatter {
    static let dateFormatter : DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter
    }()
    
    static let displayDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
}

extension String {
    static func formattedDate(dateString: String) -> String {
        guard let date = DateFormatter.dateFormatter.date(from: dateString)
        else {
            return dateString
        }
        return DateFormatter.displayDateFormatter.string(from: date)
    }
}

extension UINavigationController {
    func setUpNavForMainView(vc: UIViewController,title: String,uiImageSystemName : String) -> UINavigationController{
        self.viewControllers.first?.setUpWithLargeTitleDisplayMode()
        self.navigationBar.prefersLargeTitles = true
        self.navigationBar.tintColor = .label
        self.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: uiImageSystemName), tag: 1)
        return self;
    }
}

extension UIViewController {
    func setUpWithLargeTitleDisplayMode(titleText: String? = nil) {
        if let title = titleText {
            self.title = title
        }
        self.navigationItem.largeTitleDisplayMode = .always
    }
    
    func setUpWithLargeTitleDisplayModerNever() {
        self.navigationItem.largeTitleDisplayMode = .never
    }
}

extension Notification.Name {
    static let albumSavedNotification = Notification.Name("albumSavedNotification")
}
