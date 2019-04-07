//
//  StartController.swift
//  AfricanStories
//
//  Created by Bernie Cartin on 11/27/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import Lottie
import Firebase
import CoreData

class StartController: UIViewController, Alertable {
    
    let backgroundImage: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "AppOpeningScreen"))
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let titleImageLeft: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "rubies"))
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.alpha = 0
        return iv
    }()
    
    let titleImageRight: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "africa"))
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.alpha = 0
        return iv
    }()
    
    let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.alpha = 0
        button.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        return button
    }()
    
    let startLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap the elephant to start"
        
        label.textColor = .white
        label.alpha = 0
        label.textAlignment = .center
        return label
    }()
    
    let animationView: LOTAnimationView = {
        let view = LOTAnimationView(name: "books")
        view.backgroundColor = .clear
        return view
    }()
    
    let noInternetContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.8)
        return view
    }()
    
    let loadingContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.8)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        deleteCoreData()
        
        UserDefaults.standard.set(0, forKey: C_FILTER)
        setupUI()
        checkIfFirstRun()
        
    }
    
    func deleteCoreData() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: C_STORIES)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            print("Stories Cleared")
        } catch {
            print("There was an error deleting.")
        }
        
        let pageDeleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: C_PAGES)
        let pageDeleteRequest = NSBatchDeleteRequest(fetchRequest: pageDeleteFetch)
        
        do {
            try context.execute(pageDeleteRequest)
            try context.save()
            print("Pages Cleared")
        } catch {
            print("There was an error deleting.")
        }
        
        let glossaryDeleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: C_GLOSSARY)
        let glossaryDeleteRequest = NSBatchDeleteRequest(fetchRequest: glossaryDeleteFetch)
        
        do {
            try context.execute(glossaryDeleteRequest)
            try context.save()
            print("Glossary Cleared")
        } catch {
            print("There was an error deleting.")
        }
        
        UserDefaults.standard.set(false, forKey: C_FIRSTLOADCOMPLETE)
        UserDefaults.standard.set("1999-01-01", forKey: C_LASTUPDATE)
    }
    
    fileprivate func setupUI() {
        navigationController?.isNavigationBarHidden = true
        view.addSubview(backgroundImage)
        backgroundImage.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        view.addSubview(titleImageLeft)
        titleImageLeft.centerVertically(in: view, offset: 0)
        titleImageLeft.centerHorizontaly(in: view, offset: -view.frame.width/3.1)
        titleImageLeft.setSizeAnchors(height: 150, width: view.frame.width/4)
        
        view.addSubview(titleImageRight)
        titleImageRight.centerVertically(in: view, offset: 0)
        titleImageRight.centerHorizontaly(in: view, offset: view.frame.width/3.1)
        titleImageRight.setSizeAnchors(height: 150, width: view.frame.width/4)
        
        view.addSubview(startButton)
        startButton.centerHorizontaly(in: view, offset: 0)
        startButton.centerVertically(in: view, offset: 0)
        startButton.setSizeAnchors(height: 200, width: 200)

        startLabel.font = UIFont.defaultFontLarge()
        view.addSubview(startLabel)
        startLabel.centerHorizontaly(in: view, offset: 0)
        
        switch deviceType {
        case .iPhone:
            startLabel.centerVertically(in: view, offset: -150)
        case .iPad:
            startLabel.centerVertically(in: view, offset: -view.frame.height / 4)
        }
        
    }
    
    fileprivate func displayTitle() {
        UIView.animate(withDuration: 2, animations: {
            self.titleImageLeft.alpha = 1
            self.titleImageRight.alpha = 1
        }) { (finished) in
            UIView.animate(withDuration: 0.5) {
                self.startButton.alpha = 1
                self.startLabel.alpha = 1
            }
        }
    }
    
    @objc fileprivate func startTapped() {
        UIView.animate(withDuration: 1, animations: {
            self.startLabel.center.y = self.startLabel.center.y - self.view.frame.height / 2
            self.titleImageRight.center.x = self.titleImageRight.center.x + self.view.frame.width / 2
            self.titleImageLeft.center.x = self.titleImageLeft.center.x - self.view.frame.width / 2
        }) { (finished) in
            let vc = MainViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @objc fileprivate func checkIfFirstRun() {
        let firstLoadComplete = UserDefaults.standard.bool(forKey: C_FIRSTLOADCOMPLETE)
        if (!firstLoadComplete) {
            DataService.shared.savePreloadedStoriesToCoreData { (error) in
                if let err = error {
                    self.shouldPresentDownloadingContentView(false)
                    self.showAlert(title: C_ERROR, msg: err.localizedDescription)
                    UserDefaults.standard.set(false, forKey: C_FIRSTLOADCOMPLETE)
                    return
                }
                DataService.shared.saveFirstStoryPages(handler: { (error) in
                    if let err = error {
                        self.shouldPresentDownloadingContentView(false)
                        self.showAlert(title: C_ERROR, msg: err.localizedDescription)
                        UserDefaults.standard.set(false, forKey: C_FIRSTLOADCOMPLETE)
                        return
                    }
                    UserDefaults.standard.set(true, forKey: C_FIRSTLOADCOMPLETE)
                })
                self.checkIfUpdateAvailable { (updateAvailable) in
                    if updateAvailable {
                        self.showMessageScreen(message: "New Content Available! \n \n Getting new content involves downloading a large amount of data, it is recommended that you're connected to a wifi network before downloading new content.")
                    }
                    else {
                        self.displayTitle()
                    }
                }
            }
        }
        else {
            self.checkIfUpdateAvailable { (updateAvailable) in
                if updateAvailable {
                    self.showMessageScreen(message: "New Content Available! \n \n Getting new content involves downloading a large amount of data, it is recommended that you're connected to a wifi network before downloading new content.")
                }
                else {
                    self.displayTitle()
                }
            }
        }
    }
    
    fileprivate func downloadGlossary() {
        let glossary = GlossaryList()
        glossary.loadWordsFromWeb()
    }
    
    fileprivate func downloadStories() {
        DataService.shared.downloadStoriesfromWeb { (error) in
            self.loadingContainerView.removeFromSuperview()
            self.displayTitle()
            if let err = error {
                self.showAlert(title: "ERROR", msg: "There was an error downloading new content.")
                print(err.localizedDescription)
                UserDefaults.standard.set("1999-01-01", forKey: C_LASTUPDATE)
                return
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let lastUpdateDateString = formatter.string(from: Date())
            UserDefaults.standard.set(lastUpdateDateString, forKey: C_LASTUPDATE)
        }
    }
    
    fileprivate func checkIfUpdateAvailable(handler: @escaping (_ updateAvailable: Bool) -> Void) {
        if Internet.isConnected() {
            Database.database().reference().child(C_LASTUPDATE).observe(.value) { (snapshot) in
                let serverLastUpdateString = snapshot.value as! String
                let appLastUpdateString = UserDefaults.standard.string(forKey: C_LASTUPDATE) ?? "1999-01-01"
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                guard let serverLastUpdateDate = formatter.date(from: serverLastUpdateString) else {return}
                guard let appLastUpdateDate = formatter.date(from: appLastUpdateString) else {return}
                let newUpdate = serverLastUpdateDate > appLastUpdateDate ? true : false
                handler(newUpdate)
            }
        }
        else {
            handler(false)
        }
        
    }
    
    fileprivate func showNoConnectionErrorScreen() {

        let animationView: LOTAnimationView = {
            let view = LOTAnimationView(name: "no_connection")
            view.backgroundColor = .clear
            return view
        }()
        
        let noConnectionLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.defaultFont()
            label.text = "No Internet Connection"
            label.textColor = .white
            label.textAlignment = .center
            return label
        }()
        
        let descriptionLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.defaultFont()
            label.text = "African Stories requires an internet connection to complete setup the first time it runs. After the setup is complete the app can be used offline."
            label.textColor = .white
            label.numberOfLines = 0
            label.textAlignment = .center
            return label
        }()
        
        let tryAgainButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Try Again", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(tryAgainTapped), for: .touchUpInside)
            return button
        }()
        
        view.addSubview(noInternetContainerView)
        noInternetContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        noInternetContainerView.addSubview(noConnectionLabel)
        noConnectionLabel.centerHorizontaly(in: noInternetContainerView, offset: 0)
        noConnectionLabel.anchor(top: noInternetContainerView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        animationView.setSizeAnchors(height: 100, width: 100)
        noInternetContainerView.addSubview(animationView)
        animationView.centerHorizontaly(in: noInternetContainerView, offset: 0)
        animationView.anchor(top: noConnectionLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        noInternetContainerView.addSubview(descriptionLabel)
        descriptionLabel.anchor(top: animationView.bottomAnchor, left: noInternetContainerView.leftAnchor, bottom: nil, right: noInternetContainerView.rightAnchor, paddingTop: 20, paddingLeft: 50, paddingBottom: 0, paddingRight: 50)
        
        noInternetContainerView.addSubview(tryAgainButton)
        tryAgainButton.centerHorizontaly(in: noInternetContainerView, offset: 0)
        tryAgainButton.anchor(top: descriptionLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        animationView.play()
    }
    
    @objc fileprivate func tryAgainTapped() {
        noInternetContainerView.removeFromSuperview()
        downloadUpdates()
    }
    
    fileprivate func showMessageScreen(message: String) {
        let containerView: UIView = {
            let view = UIView()
            view.tag = 99
            view.backgroundColor = UIColor(white: 0, alpha: 0.8)
            return view
        }()
        
        let messageLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.defaultFont()
            label.text = message
            label.textColor = .white
            label.numberOfLines = 0
            label.textAlignment = .center
            return label
        }()
        
        let continueButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitleColor(.white, for: .normal)
            button.setTitle("Continue", for: .normal)
            button.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
            return button
        }()
        
        let laterButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitleColor(.white, for: .normal)
            button.setTitle("Do It Later", for: .normal)
            button.addTarget(self, action: #selector(laterTapped), for: .touchUpInside)
            return button
        }()
        
        view.addSubview(containerView)
        containerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        containerView.addSubview(messageLabel)
        messageLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 30, paddingBottom: 0, paddingRight: 30)
        messageLabel.centerVertically(in: containerView, offset: -50)
        
        let buttonsStackView = UIStackView(arrangedSubviews: [continueButton, laterButton])
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 100
        
        containerView.addSubview(buttonsStackView)
        buttonsStackView.centerHorizontaly(in: containerView, offset: 0)
        buttonsStackView.anchor(top: messageLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
    }
    
    @objc fileprivate func laterTapped() {
        let messageView = self.view.viewWithTag(99)
        messageView?.removeFromSuperview()
        displayTitle()
    }
    
    @objc fileprivate func continueTapped() {
        let messageView = self.view.viewWithTag(99)
        messageView?.removeFromSuperview()
        downloadUpdates()
    }
    
    fileprivate func downloadUpdates() {
        if Internet.isConnected() {
            self.showLoadingScreen(message: "Downloading New Content. Please Wait")
            self.downloadStories()
            self.downloadGlossary()
        }
        else {
            showNoConnectionErrorScreen()
        }
    }
    
    fileprivate func showLoadingScreen(message: String) {
        
        let animationView: LOTAnimationView = {
            let view = LOTAnimationView(name: "wave_loading")
            view.backgroundColor = .clear
            view.loopAnimation = true
            view.autoReverseAnimation = true
            return view
        }()
        
        let descriptionLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.defaultFont()
            label.text = message
            label.textColor = .white
            label.numberOfLines = 0
            label.textAlignment = .center
            return label
        }()
        
        view.addSubview(loadingContainerView)
        loadingContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        animationView.setSizeAnchors(height: 200, width: 200)
        loadingContainerView.addSubview(animationView)
        animationView.centerHorizontaly(in: loadingContainerView, offset: 0)
        animationView.centerVertically(in: loadingContainerView, offset: -50)
        
        loadingContainerView.addSubview(descriptionLabel)
        descriptionLabel.anchor(top: animationView.bottomAnchor, left: loadingContainerView.leftAnchor, bottom: nil, right: loadingContainerView.rightAnchor, paddingTop: -40, paddingLeft: 50, paddingBottom: 0, paddingRight: 50)
        
        animationView.play()
    }

}
