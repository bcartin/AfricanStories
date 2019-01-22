//
//  General.swift
//  AfricanStories
//
//  Created by Bernie Cartin on 11/8/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import Lottie

extension Notification.Name {
    static let purchaseSuccesful = Notification.Name(C_PURCHASESUCCESSFULL)
    static let restoreSuccessful = Notification.Name(C_RESTORESUCCESSFUL)
    static let purchaseFailed = Notification.Name(C_PURCHASEFAILED)
}

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static func mainBlue() -> UIColor {
        return UIColor.rgb(red: 17, green: 154, blue: 237)
    }
    
    
}

extension UIFont {
    
    static func defaultFont() -> UIFont {
        switch deviceType {
        case .iPad:
            return UIFont(name: "MarkerFelt-Thin", size: 32)!
        case .iPhone:
            return UIFont(name: "MarkerFelt-Thin", size: 16)!
        }
    }
    
    static func defaultFontLarge() -> UIFont {
        switch deviceType {
        case .iPad:
            return UIFont(name: "MarkerFelt-Thin", size: 36)!
        case .iPhone:
            return UIFont(name: "MarkerFelt-Thin", size: 20)!
        }
    }
    
    static func defaultFontSmall() -> UIFont {
        switch deviceType {
        case .iPad:
            return UIFont(name: "MarkerFelt-Thin", size: 18)!
        case .iPhone:
            return UIFont(name: "MarkerFelt-Thin", size: 12)!
        }
    }
    
}

extension UIViewController {
    
    func shouldPresentLoadingView(_ status: Bool) {
        var fadeView: UIView?
        
        if status == true {
            fadeView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
            fadeView?.backgroundColor = UIColor.black
            fadeView?.alpha = 0.0
            fadeView?.tag = 98
            let spinner = UIActivityIndicatorView()
            spinner.color = UIColor.white
            spinner.style = .whiteLarge
            spinner.center = view.center
            view.addSubview(fadeView!)
            fadeView?.addSubview(spinner)
            spinner.startAnimating()
            fadeView?.fadeTo(alphaValue: 0.8, withDuration: 0.2)
        }
        else {
            for subView in view.subviews {
                if subView.tag == 98 {
                    UIView.animate(withDuration: 0.2, animations: {
                        subView.alpha = 0.0
                    }, completion: { (finished) in
                        subView.removeFromSuperview()
                    })
                }
            }
        }
    }
    
    func shouldPresentDownloadingContentView(_ status: Bool) {
        var fadeView: UIView?
        
        if status == true {
            fadeView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
            fadeView?.backgroundColor = UIColor.black
            fadeView?.alpha = 0.0
            fadeView?.tag = 99
            
            let animationView = LOTAnimationView(name: "wave_loading")
            animationView.backgroundColor = .clear
            animationView.loopAnimation = true
            animationView.autoReverseAnimation = true
            
            let messageLabel = UILabel()
            messageLabel.font = UIFont.defaultFont()
            messageLabel.text = "Downloading Content. Please Wait."
            messageLabel.textColor = .white
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            
            view.addSubview(fadeView!)
            animationView.setSizeAnchors(height: 200, width: 200)
            fadeView?.addSubview(animationView)
            animationView.centerHorizontaly(in: fadeView!, offset: 0)
            animationView.centerVertically(in: fadeView!, offset: -50)
            animationView.play()
            
            fadeView?.addSubview(messageLabel)
            messageLabel.anchor(top: animationView.bottomAnchor, left: fadeView?.leftAnchor, bottom: nil, right: fadeView?.rightAnchor, paddingTop: -40, paddingLeft: 50, paddingBottom: 0, paddingRight: 50)
            
            fadeView?.fadeTo(alphaValue: 0.8, withDuration: 0.2)
        }
        else {
            for subView in view.subviews {
                if subView.tag == 99 {
                    UIView.animate(withDuration: 0.2, animations: {
                        subView.alpha = 0.0
                    }, completion: { (finished) in
                        subView.removeFromSuperview()
                    })
                }
            }
        }
    }
    
}

protocol Alertable {}

extension Alertable where Self: UIViewController {
    
    func showAlert(title: String, msg: String?) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    func showMessage(message: String, center: CGPoint?) {
        DispatchQueue.main.async {
            let savedLabel = UILabel()
            savedLabel.text = message
            savedLabel.textColor = .white
            savedLabel.numberOfLines = 0
            savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
            savedLabel.font = UIFont.boldSystemFont(ofSize: 18)
            savedLabel.textAlignment = .center
            savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
            if let center = center {
                savedLabel.center = center
            }
            else {
                savedLabel.center = self.view.center
            }
            self.view.addSubview(savedLabel)
            savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
            }, completion: { (completed) in
                //COMPLETED ANIMATION
                UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    savedLabel.layer.transform = CATransform3DMakeScale(0.01, 0.01, 0.01)
                    savedLabel.alpha = 0
                }, completion: { (_) in
                    savedLabel.removeFromSuperview()
                })
            })
        }
    }
}
