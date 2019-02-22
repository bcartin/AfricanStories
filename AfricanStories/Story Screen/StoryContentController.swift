//
//  StoryContentController.swift
//  AfricanStories
//
//  Created by Bernie Cartin on 11/6/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit

class StoryContentController: UIViewController {
    
    let audioOnImage = UIImage(named: "audio_on.png")?.withRenderingMode(.alwaysOriginal)
    let audioOffImage = UIImage(named: "audio_off.png")?.withRenderingMode(.alwaysOriginal)
    var glossaryViewController: GlossaryController!
    
    var isFinished = false
    var isGlossaryShowing = false
    var pageNumber: Int?
    var pageNumberString: String?
    var storyStartText = ""
    var storyText: String? {
        didSet {
            storyTextLabel.text = storyText
            animateText()
        }
    }
    var invisibleText: String?
    
    var author = ""
    var editor = ""
    var illustrator = ""
    var creativeDirector = ""
    
    let homeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "home").withRenderingMode(.alwaysOriginal), for: .normal)
        button.alpha = 0.7
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.clipsToBounds = true
        button.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let audioButton: UIButton = {
        let button = UIButton(type: .system)
        button.alpha = 0.7
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.clipsToBounds = true
        button.addTarget(self, action: #selector(audioButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let glossaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "Glossary").withRenderingMode(.alwaysOriginal), for: .normal)
        button.alpha = 0.7
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.clipsToBounds = true
        button.addTarget(self, action: #selector(glossaryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let pageNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(white: 1, alpha: 0.8)
        return label
    }()
    
    let backgroundImage: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "background22"))
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let textContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.8)
        view.layer.cornerRadius = 10
        return view
    }()
    
    let invisibleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.defaultFont()
        label.textColor = UIColor.clear
        label.numberOfLines = 0
        return label
    }()
    
    let storyTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.defaultFont()
        label.textColor = .black
        label.layer.cornerRadius = 10
        label.numberOfLines = 0
        label.alpha = 0
        return label
    }()
    
    let storyImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    
    fileprivate func setupUI() {
        view.addSubview(backgroundImage)
        backgroundImage.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        let height: CGFloat = view.frame.height

        view.addSubview(storyImage)
        storyImage.setSizeAnchors(height: height, width: height / 0.75)
        storyImage.centerHorizontaly(in: view, offset: 0)
        storyImage.centerVertically(in: view, offset: 0)
        
        if isFinished {
            showCreditsView()
        }
        
        view.addSubview(homeButton)
        homeButton.setSizeAnchors(height: 40, width: 40)
        homeButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 30)
        
        view.addSubview(audioButton)
        audioButton.setSizeAnchors(height: 40, width: 40)
        audioButton.anchor(top: homeButton.bottomAnchor, left: nil, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 30)
        
        pageNumberLabel.text = pageNumberString
        view.addSubview(pageNumberLabel)
        pageNumberLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 30, paddingBottom: 0, paddingRight: 0)
        
        view.addSubview(glossaryButton)
        glossaryButton.setSizeAnchors(height: 40, width: 40)
        glossaryButton.anchor(top: pageNumberLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 30, paddingBottom: 0, paddingRight: 0)

        view.addSubview(textContainerView)
        textContainerView.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 10, paddingRight: 10)

        invisibleLabel.text = invisibleText
        textContainerView.addSubview(invisibleLabel)
        invisibleLabel.anchor(top: textContainerView.topAnchor, left: textContainerView.leftAnchor, bottom: textContainerView.bottomAnchor, right: textContainerView.rightAnchor, paddingTop: 5, paddingLeft: 15, paddingBottom: 10, paddingRight: 15)

        storyTextLabel.text = storyText
        textContainerView.addSubview(storyTextLabel)
        storyTextLabel.anchor(top: textContainerView.topAnchor, left: textContainerView.leftAnchor, bottom: nil, right: textContainerView.rightAnchor, paddingTop: 5, paddingLeft: 15, paddingBottom: 5, paddingRight: 15)
        
        glossaryViewController = GlossaryController()
        self.addChild(glossaryViewController)
        self.view.addSubview(glossaryViewController.view)
        
        glossaryViewController.view.frame = CGRect(x: view.frame.width / 2 - (view.frame.width / 3), y: view.frame.height, width: view.frame.width / 1.5, height: view.frame.height)
        
        glossaryViewController.view.clipsToBounds = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        switch isSoundOn {
        case true:
            audioButton.setImage(audioOnImage, for: .normal)
        case false:
            audioButton.setImage(audioOffImage, for: .normal)
        }
    }
    
    @objc fileprivate func homeButtonTapped() {
        storyPlayer.stop()
        navigationController?.popViewController(animated: true)

        
    }
    
    fileprivate func animateText() {
        UIView.animate(withDuration: 1) {
            self.storyTextLabel.alpha = 1
        }
    }
    
    @objc fileprivate func audioButtonTapped() {
        if isSoundOn {
            storyPlayer.pause()
            audioButton.setImage(audioOffImage, for: .normal)
        }
        else {
            storyPlayer.play()
            audioButton.setImage(audioOnImage, for: .normal)
        }
        isSoundOn = !isSoundOn
        UserDefaults.standard.set(isSoundOn, forKey: "isSoundOn")
    }
    
    @objc fileprivate func glossaryButtonTapped() {
        var point: CGFloat
        if isGlossaryShowing { point = view.frame.width }
        else { point = 0 }
        UIView.animate(withDuration: 1) {
            self.glossaryViewController.view.frame.origin.y = point
            self.view.layoutIfNeeded()
        }
        isGlossaryShowing = !isGlossaryShowing
    }
    
    func showCreditsView() {
        
        let creditsView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(white: 1, alpha: 0.5)
            return view
        }()
        
        let endTitle: UILabel = {
            let label = UILabel()
            label.font = UIFont.defaultFontLarge()
            label.text = "THE END"
            return label
        }()
        
        let authorLabel: UILabel = {

            let attributedText = NSMutableAttributedString(string: "Author(s): ", attributes: [NSAttributedString.Key.font: UIFont.defaultFont(), NSAttributedString.Key.foregroundColor: UIColor.black])
            attributedText.append(NSMutableAttributedString(string: author, attributes: [NSAttributedString.Key.font: UIFont.defaultFont(), NSAttributedString.Key.foregroundColor: UIColor.gray]))
            let label = UILabel()
            label.attributedText = attributedText
            label.textAlignment = .center
            return label
        }()
        
        let illustratorLabel: UILabel = {
            let attributedText = NSMutableAttributedString(string: "Illustrator(s): ", attributes: [NSAttributedString.Key.font: UIFont.defaultFont(), NSAttributedString.Key.foregroundColor: UIColor.black])
            attributedText.append(NSMutableAttributedString(string: illustrator, attributes: [NSAttributedString.Key.font: UIFont.defaultFont(), NSAttributedString.Key.foregroundColor: UIColor.gray]))
            let label = UILabel()
            label.attributedText = attributedText
            label.textAlignment = .center
            return label
        }()
        
        let editorLabel: UILabel = {
            let attributedText = NSMutableAttributedString(string: "Editor: ", attributes: [NSAttributedString.Key.font: UIFont.defaultFont(), NSAttributedString.Key.foregroundColor: UIColor.black])
            attributedText.append(NSMutableAttributedString(string: editor, attributes: [NSAttributedString.Key.font: UIFont.defaultFont(), NSAttributedString.Key.foregroundColor: UIColor.gray]))
            let label = UILabel()
            label.attributedText = attributedText
            label.textAlignment = .center
            return label
        }()
        
        let creativeLabel: UILabel = {
            let attributedText = NSMutableAttributedString(string: "Creative Director: ", attributes: [NSAttributedString.Key.font: UIFont.defaultFont(), NSAttributedString.Key.foregroundColor: UIColor.black])
            attributedText.append(NSMutableAttributedString(string: creativeDirector, attributes: [NSAttributedString.Key.font: UIFont.defaultFont(), NSAttributedString.Key.foregroundColor: UIColor.gray]))
            let label = UILabel()
            label.attributedText = attributedText
            label.textAlignment = .center
            return label
        }()
        
        let dividerView = UIView()
        dividerView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        
        let shareLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.defaultFont()
            label.text = "Did you like this story? Spread the word!"
            label.textAlignment = .center
            return label
        }()
        
        let facebookButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "facebook").withRenderingMode(.alwaysOriginal), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
            return button
        }()
        
        let twitterButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "twitter").withRenderingMode(.alwaysOriginal), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
            return button
        }()
        
        let instagramButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "instagram").withRenderingMode(.alwaysOriginal), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
            return button
        }()
        
        let shareButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "share").withRenderingMode(.alwaysOriginal), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
            return button
        }()
        
        let divider2View = UIView()
        divider2View.backgroundColor = UIColor(white: 0, alpha: 0.3)
        
        let iconsLabel: UILabel = {
            let attributedText = NSMutableAttributedString(string: "Icons: ", attributes: [NSAttributedString.Key.font: UIFont.defaultFontSmall(), NSAttributedString.Key.foregroundColor: UIColor.white])
            attributedText.append(NSMutableAttributedString(string: "Google, Freepik, Dave Gandy, Oluwagbenga Jesubanjo", attributes: [NSAttributedString.Key.font: UIFont.defaultFontSmall(), NSAttributedString.Key.foregroundColor: UIColor.white]))
            let label = UILabel()
            label.attributedText = attributedText
            label.textAlignment = .center
            return label
        }()
        
        let musicLabel: UILabel = {
            let attributedText = NSMutableAttributedString(string: "Music: ", attributes: [NSAttributedString.Key.font: UIFont.defaultFontSmall(), NSAttributedString.Key.foregroundColor: UIColor.white])
            attributedText.append(NSMutableAttributedString(string: "bensound.com", attributes: [NSAttributedString.Key.font: UIFont.defaultFontSmall(), NSAttributedString.Key.foregroundColor: UIColor.white]))
            let label = UILabel()
            label.attributedText = attributedText
            label.textAlignment = .center
            return label
        }()
        
        let copyrightLabel: UILabel = {
            let attributedText = NSMutableAttributedString(string: "Copyright: ", attributes: [NSAttributedString.Key.font: UIFont.defaultFontSmall(), NSAttributedString.Key.foregroundColor: UIColor.white])
            attributedText.append(NSMutableAttributedString(string: "FamilyRubies", attributes: [NSAttributedString.Key.font: UIFont.defaultFontSmall(), NSAttributedString.Key.foregroundColor: UIColor.white]))
            let label = UILabel()
            label.attributedText = attributedText
            label.textAlignment = .center
            return label
        }()
        
        

        view.addSubview(creditsView)
        
        creditsView.anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        creditsView.setSizeAnchors(height: nil, width: view.frame.width / 1.5)
        creditsView.centerHorizontaly(in: view, offset: 0)
        
        creditsView.addSubview(endTitle)
        switch deviceType {
        case .iPhone:
            endTitle.anchor(top: creditsView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        case .iPad:
            endTitle.anchor(top: creditsView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 200, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        }
        
        endTitle.centerHorizontaly(in: creditsView, offset: 0)
        
        let creditsStackView = UIStackView(arrangedSubviews: [authorLabel, illustratorLabel, editorLabel, creativeLabel])
        creditsStackView.axis = .vertical
        creditsStackView.spacing = 10
        
        creditsView.addSubview(creditsStackView)
        creditsStackView.anchor(top: endTitle.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        creditsStackView.centerHorizontaly(in: creditsView, offset: 0)
        
        creditsView.addSubview(dividerView)
        dividerView.anchor(top: creditsStackView.bottomAnchor, left: creditsView.leftAnchor, bottom: nil, right: creditsView.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        dividerView.setSizeAnchors(height: 1, width: 0)
        
        creditsView.addSubview(shareLabel)
        shareLabel.anchor(top: dividerView.bottomAnchor, left: creditsView.leftAnchor, bottom: nil, right: creditsView.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        let iconSize: CGFloat
        switch deviceType {
        case .iPad:
            iconSize = 80
        case .iPhone:
            iconSize = 40
        }
        
        facebookButton.setSizeAnchors(height: iconSize, width: iconSize)
        twitterButton.setSizeAnchors(height: iconSize, width: iconSize)
        instagramButton.setSizeAnchors(height: iconSize, width: iconSize)
        shareButton.setSizeAnchors(height: iconSize, width: iconSize)
        
        let shareStackView = UIStackView(arrangedSubviews: [facebookButton, twitterButton, instagramButton, shareButton])
        shareStackView.axis = .horizontal
        shareStackView.spacing = 30
        
        creditsView.addSubview(shareStackView)
        shareStackView.anchor(top: shareLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        shareStackView.centerHorizontaly(in: creditsView, offset: 0)
        
        creditsView.addSubview(divider2View)
        divider2View.anchor(top: shareStackView.bottomAnchor, left: creditsView.leftAnchor, bottom: nil, right: creditsView.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        divider2View.setSizeAnchors(height: 1, width: 0)
        
        let appCreditsStackView = UIStackView(arrangedSubviews: [iconsLabel, musicLabel, copyrightLabel])
        appCreditsStackView.axis = .vertical
        appCreditsStackView.spacing = 2
        
        creditsView.addSubview(appCreditsStackView)
        appCreditsStackView.anchor(top: divider2View.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        appCreditsStackView.centerHorizontaly(in: creditsView, offset: 0)
        
        

    }
    
    @objc fileprivate func shareTapped() {
        
        guard let url = URL(string: "http://www.familyrubies.com/app") else {return}
        let shareText = "Just read a great story on Rubies Africa!"
        
        let items: [Any] = [shareText, url]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if deviceType == .iPad {
            ac.modalPresentationStyle = .popover
            if let popoverController = ac.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            }
        }
        present(ac, animated: true)
        
    }

}

