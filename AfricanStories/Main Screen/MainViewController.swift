//
//  MainViewController.swift
//  StoriesDev
//
//  Created by Bernie Cartin on 11/3/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
import FirebaseAuth

enum bookFrameColor: String {
    case blue = "bookBlue.png"
    case red = "bookRed.png"
    case green = "bookGreen.png"
    case yellow = "bookYellow.png"
}

class MainViewController: UIViewController, Alertable {
    
    let filter = ["All Stories", "Ages 4-6", "Ages 7-12", "Ages 13 and above"]
    
    var thumbnailZoomTransitionAnimator: AnimationTransition?
    var transitionThumbnail: UIImageView?
    var nextFrameColor: bookFrameColor = .blue
    
    let bookLayout = BooksLayout()
    var booksCollectionView: UICollectionView!
    
    let stories = StoryCollection()
    var filteredStories: [Story] = []
    
    let audioOnImage = UIImage(named: "audio_on.png")?.withRenderingMode(.alwaysOriginal)
    let audioOffImage = UIImage(named: "audio_off.png")?.withRenderingMode(.alwaysOriginal)
    
    var storyFilter = UserDefaults.standard.integer(forKey: C_FILTER) {
        didSet {
            UserDefaults.standard.set(storyFilter, forKey: C_FILTER)
            filterStories()
        }
    }
    
    
    
    let backgroundImage: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "sunsetBackground"))
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let audioButton: UIButton = {
        let button = UIButton(type: .system)
        button.alpha = 0.7
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.clipsToBounds = true
        button.addTarget(self, action: #selector(audioButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let contactButton: UIButton = {
        let button = UIButton(type: .system)
        button.alpha = 0.7
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.clipsToBounds = true
        button.setImage(#imageLiteral(resourceName: "contact").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(contactButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let restoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.alpha = 0.7
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.clipsToBounds = true
        button.setImage(#imageLiteral(resourceName: "restore").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(restoreButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.alpha = 0.7
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.clipsToBounds = true
        button.setImage(#imageLiteral(resourceName: "filter").withRenderingMode(.alwaysOriginal), for: .normal)
                button.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        return button
    }()
    
    let filterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.defaultFontLarge()
        label.textColor = UIColor(white: 1, alpha: 0.7)
        return label
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signOut()
        setupUI()
        setupDelegates()
        stories.loadStoriesFromCoreData { (error) in
            if let err = error {
                print("ERROR: " + err.localizedDescription)
                return
            }
            self.filterStories()
            let set = Set(self.stories.booksSet)
            IAPService.shared.getBooks(booksSet: set)
            NotificationCenter.default.addObserver(self, selector: #selector(self.completePurchase(_:)), name: .purchaseSuccesful, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.purchaseFailed(_:)), name: .purchaseFailed, object: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        switch isSoundOn {
        case true:
            audioButton.setImage(audioOnImage, for: .normal)
            if !player.isPlaying {
                player.play()
            }
        case false:
            audioButton.setImage(audioOffImage, for: .normal)
        }
    }
    
    fileprivate func setupUI() {
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = UIColor.rgb(red: 173, green: 222, blue: 236)
        
        view.addSubview(backgroundImage)
        backgroundImage.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        let height: CGFloat
        
        switch deviceType {
        case .iPad:
            height = view.frame.height * 0.6
        case .iPhone:
            height = view.frame.height - 100
        }
        
        bookLayout.itemSize = CGSize(width: height/0.85, height: height)
        bookLayout.PageWidth = height/0.85
        bookLayout.PageHeight = height

        booksCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), collectionViewLayout: bookLayout)
        booksCollectionView.backgroundColor = UIColor.clear
        booksCollectionView.showsHorizontalScrollIndicator = false
        
        view.addSubview(booksCollectionView)
        
        view.addSubview(audioButton)
        audioButton.setSizeAnchors(height: 40, width: 40)
        audioButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 10)
        
        view.addSubview(contactButton)
        contactButton.setSizeAnchors(height: 40, width: 40)
        contactButton.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 10)
        
        view.addSubview(restoreButton)
        restoreButton.setSizeAnchors(height: 40, width: 40)
        restoreButton.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 10, paddingRight: 0)
        
        view.addSubview(filterButton)
        filterButton.setSizeAnchors(height: 40, width: 40)
        filterButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 0)
        
        filterLabel.text = filter[0]
        view.addSubview(filterLabel)
        filterLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: filterButton.rightAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 5, paddingBottom: 0, paddingRight: 0)

    }
    
    fileprivate func setupDelegates() {
        booksCollectionView.delegate = self
        booksCollectionView.dataSource = self
        booksCollectionView.register(BookCoverCell.self, forCellWithReuseIdentifier: "cellId")
        navigationController?.delegate = self
        transitioningDelegate = self
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            print("Signed Out")
        }
        catch {
            print("Error Logging Out")
        }
    }
    
    @objc fileprivate func audioButtonTapped() {
        if isSoundOn {
            player.pause()
            audioButton.setImage(audioOffImage, for: .normal)
        }
        else {
            player.play()
            audioButton.setImage(audioOnImage, for: .normal)
        }
        isSoundOn = !isSoundOn
        UserDefaults.standard.set(isSoundOn, forKey: "isSoundOn")
    }
    
    @objc fileprivate func filterTapped() {
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: self.view.frame.width ,height: 150)
        let filterPicker = UIPickerView()
        filterPicker.delegate = self
        filterPicker.dataSource = self
        filterPicker.selectRow(0, inComponent: 0, animated: false)
        vc.view.addSubview(filterPicker)
        filterPicker.anchor(top: vc.view.safeAreaLayoutGuide.topAnchor, left: vc.view.safeAreaLayoutGuide.leftAnchor, bottom: vc.view.safeAreaLayoutGuide.bottomAnchor, right: vc.view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        let filterAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        filterAlert.setValue(vc, forKey: "contentViewController")
        filterAlert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { (done) in
            self.filterLabel.text = self.filter[filterPicker.selectedRow(inComponent: 0)]
            self.storyFilter = filterPicker.selectedRow(inComponent: 0)
        }))
        self.present(filterAlert, animated: true)
    }
    
    fileprivate func filterStories() {
        self.filteredStories.removeAll()
        switch storyFilter {
        case 0: filteredStories = stories.collection
        case 1: filteredStories = stories.collection.filter {$0.ageGroup1 == true}
        case 2: filteredStories = stories.collection.filter {$0.ageGroup2 == true}
        case 3: filteredStories = stories.collection.filter {$0.ageGroup3 == true}
        default: filteredStories = stories.collection
        }
        
        self.addLastCell()
        booksCollectionView.reloadData()
    }
    
    @objc fileprivate func restoreButtonTapped() {
        self.shouldPresentDownloadingContentView(true)
        IAPService.shared.restorePurchases()
    }
    
    @objc fileprivate func contactButtonTapped() {
        
        let url = URL(string: "mailto:info@familyrubies.com")
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
    fileprivate func addLastCell() {
        var storyDictionary: [String:Any] = [:]
        storyDictionary[C_STORYID] = "lastCell"
        storyDictionary[C_TITLE] = "lastCell"
        storyDictionary[C_ISPURCHASED] = true
        storyDictionary[C_SUMMARY] = "lastCell"
        storyDictionary[C_TOTALPAGES] = 0
        storyDictionary[C_AGEGROUP1] = true
        storyDictionary[C_AGEGROUP2] = true
        storyDictionary[C_AGEGROUP3] = true
        storyDictionary[C_AUTHOR] = ""
        storyDictionary[C_EDITOR] = ""
        storyDictionary[C_ILLUSTRATOR] = ""
        storyDictionary[C_CREATIVEDIRECTOR] = ""
        storyDictionary[C_SONG] = ""
        storyDictionary[C_COVERIMAGEURL] = ""
        storyDictionary[C_DEMOIMAGE1URL] = ""
        storyDictionary[C_DEMOIMAGE2URL] = ""
        storyDictionary[C_DEMOIMAGE3URL] = ""
        let lastCellStory = Story(storyDictionary: storyDictionary)
        filteredStories.append(lastCellStory)
    }
    
    fileprivate func addFirstCell() {
        var storyDictionary: [String:Any] = [:]
        storyDictionary[C_STORYID] = "allStories"
        storyDictionary[C_TITLE] = "allStories"
        storyDictionary[C_ISPURCHASED] = false
        storyDictionary[C_SUMMARY] = "Purchase all of our stories for a discounted price!"
        storyDictionary[C_TOTALPAGES] = 0
        storyDictionary[C_AGEGROUP1] = false
        storyDictionary[C_AGEGROUP2] = false
        storyDictionary[C_AGEGROUP3] = false
        storyDictionary[C_AUTHOR] = ""
        storyDictionary[C_EDITOR] = ""
        storyDictionary[C_ILLUSTRATOR] = ""
        storyDictionary[C_CREATIVEDIRECTOR] = ""
        storyDictionary[C_SONG] = ""
        storyDictionary[C_COVERIMAGEURL] = ""
        storyDictionary[C_DEMOIMAGE1URL] = ""
        storyDictionary[C_DEMOIMAGE2URL] = ""
        storyDictionary[C_DEMOIMAGE3URL] = ""
        let firstCellStory = Story(storyDictionary: storyDictionary)
        filteredStories.insert(firstCellStory, at: 0)
    }
    
    @objc fileprivate func completePurchase(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let storyId = userInfo[C_STORYID] as? String else {return}
        if storyId != "allStories" {
            self.doanloadStory(storyId: storyId) { (error) in
                if let err = error {
                    self.showAlert(title: "ERROR", msg: err.localizedDescription)
                    print(err.localizedDescription)
                    return
                }
                self.stories.collection.removeAll()
                self.filteredStories.removeAll()
                self.stories.loadStoriesFromCoreData(handler: { (error) in
                    if let err = error {
                        self.showAlert(title: "ERROR", msg: err.localizedDescription)
                        print(err.localizedDescription)
                        self.shouldPresentDownloadingContentView(false)
                        return
                    }
                    self.filterStories()
                    self.addLastCell()
                    self.booksCollectionView.reloadData()
                    self.shouldPresentDownloadingContentView(false)
                    self.showMessage(message: "Download Complete", center: self.view.center)
                })
            }
        }
        else {
            var count = 0
            for story in stories.collection {
                if story.isPurchased {
                    count += 1
                    continue
                }
                let storyId = story.storyId
                self.doanloadStory(storyId: storyId) { (error) in
                    if let err = error {
                        self.showAlert(title: "ERROR", msg: err.localizedDescription)
                        self.shouldPresentDownloadingContentView(false)
                        print(err.localizedDescription)
                    }
                    count += 1
                    if count == self.stories.collection.count {
                        self.stories.collection.removeAll()
                        self.filteredStories.removeAll()
                        self.stories.loadStoriesFromCoreData(handler: { (error) in
                            if let err = error {
                                self.showAlert(title: "ERROR", msg: err.localizedDescription)
                                print(err.localizedDescription)
                                self.shouldPresentDownloadingContentView(false)
                                return
                            }
                            self.filterStories()
                            self.addLastCell()
                            self.booksCollectionView.reloadData()
                            self.shouldPresentDownloadingContentView(false)
                            self.showMessage(message: "Download Complete", center: self.view.center)
                        })
                    }
                }
            }
        }
    }
    
   
    
    @objc fileprivate func purchaseFailed(_ notification: NSNotification) {
        self.showAlert(title: "ERROR", msg: "Purchase ould not be completed. \nPlease try again")
    }
    
    fileprivate func doanloadStory(storyId: String, handler: @escaping (_ error: Error?) -> Void) {
        if storyId != "allStories" {
            let purchasedStory = stories.collection.filter({$0.storyId == storyId}).first
            purchasedStory?.updateIsPurchasedStatus(to: true)
            purchasedStory?.loadPagesFromWeb(handler: { (error) in
                if let err = error {
                    handler(err)
                    return
                }
                handler(nil)
            })
        }
        else {
            handler(nil)
        }
    }
    
    
}


extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func selectedCell() -> BookCoverCell? {
        if let indexPath = booksCollectionView?.indexPathForItem(at: CGPoint(x: booksCollectionView.contentOffset.x + booksCollectionView.bounds.width / 2, y: booksCollectionView.bounds.height / 2)) {
            if let cell = booksCollectionView?.cellForItem(at: indexPath) as? BookCoverCell {
                return cell
            }
        }
        return nil
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredStories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = booksCollectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! BookCoverCell
            if indexPath.item < filteredStories.count - 1 {
            cell.delegate = self
            let storyId = filteredStories[indexPath.item].storyId
            cell.storyId = storyId
            if let price = productsPrice[storyId] {
                cell.price = price
            }
            else {
                cell.price = 1.99
            }
//            cell.price = filteredStories[indexPath.item].price
            cell.isPurchased = filteredStories[indexPath.item].isPurchased
            if cell.frameColor == nil {
                cell.frameColor = nextFrameColor
                switch nextFrameColor {
                case .blue:
                    nextFrameColor = .red
                case .red:
                    nextFrameColor = .green
                case .green:
                    nextFrameColor = .yellow
                case .yellow:
                    nextFrameColor = .blue
                }
            }
            let image = filteredStories[indexPath.item].coverImage
            cell.bookCoverImage.image = image
            cell.pagesLabel.text = String(filteredStories[indexPath.item].totalPages) + "p"
        }
        else {
            cell.frameColor = .blue
            cell.bookCoverImage.image = #imageLiteral(resourceName: "comingsoon").withRenderingMode(.alwaysOriginal)
            cell.isPurchased = true
            cell.pagesLabel.text = ""
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if indexPath.item < filteredStories.count - 1 {
            if isSoundOn {
                player.pause()
            }
            guard let cell = selectedCell() else {return}
            transitionThumbnail = cell.bookCoverImage
            if filteredStories[indexPath.item].isPurchased {
                player.stop()
                let storyDetailController = StoryController()
                let pages = self.filteredStories[indexPath.item].pages
                storyDetailController.pages = pages
                storyDetailController.story = self.filteredStories[indexPath.item]
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(storyDetailController, animated: true)
                }
                
                
            }
            else {
                let vc = PreviewController()
                vc.previewText.text = self.filteredStories[indexPath.item].summary
                vc.image1.image = self.filteredStories[indexPath.item].demoImage1
                vc.image2.image = self.filteredStories[indexPath.item].demoImage2
                vc.image3.image = self.filteredStories[indexPath.item].demoImage3
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
    }
    
    
}

extension MainViewController: UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            guard let transitionThumbnail = transitionThumbnail, let transitionThumbnailSuperview = transitionThumbnail.superview else { return nil }
            thumbnailZoomTransitionAnimator = AnimationTransition()
            thumbnailZoomTransitionAnimator?.thumbnailFrame = transitionThumbnailSuperview.convert(transitionThumbnail.frame, to: nil)
        }
        thumbnailZoomTransitionAnimator?.operation = operation
        
        return thumbnailZoomTransitionAnimator
    }
}

extension MainViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filter.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return filter[row]
    }
}

extension MainViewController: BookCoverCellDelegate {
    
    func didTapBuyButton(storyId: String) {
        self.shouldPresentDownloadingContentView(true)
        IAPService.shared.purchaseStory(product: storyId)
    }
}


