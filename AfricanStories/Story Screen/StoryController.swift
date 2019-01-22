//
//  StoryController.swift
//  AfricanStories
//
//  Created by Bernie Cartin on 11/6/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import AVFoundation

class StoryController: UIPageViewController {
    
    var pages = [Page]()    
    var pageNumbers: [String] = []
    var nextPageText: String!
    var story: Story?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        createContentPages()
        dataSource = self
        delegate = self
        let vc = StoryContentController()
        vc.pageNumber = pages[0].pageNumber
        vc.pageNumberString = pageNumbers[0]
        vc.storyText = pages[0].pageText
        vc.invisibleText = pages[0].pageText
        vc.storyImage.image = pages[0].pageImage
        setViewControllers([vc], direction: .forward, animated: true, completion: nil)
        playAudio()
    }
    
    fileprivate func setupUI() {
        view.backgroundColor = .green
    }
    
    fileprivate func playAudio() {
        guard let song = story?.song else {return}
        let storyAudioPath = Bundle.main.path(forResource: song, ofType: "mp3")
        do{
            try storyPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: storyAudioPath!))
            storyPlayer.numberOfLoops = -1
            if isSoundOn {
                storyPlayer.play()
            }
        }
        catch{
            print("ERROR PLAYING STORY AUDIO")
        }
    }
    
    fileprivate func createContentPages() {
        
        var pageStrings = [String]()
        
        for page in pages
        {
            let contentString = "\(page.pageNumber) / \(pages.count)"
            pageStrings.append(contentString)
        }
        pageNumbers = pageStrings
    }
    
    fileprivate func viewControllerAtIndex(index: Int) -> StoryContentController? {
        
        if (pages.count == 0) ||
            (index > pages.count) {
            return nil
        }
        let dataViewController = StoryContentController()
        if index == pages.count {
            dataViewController.pageNumber = pages[index-1].pageNumber + 1
            dataViewController.textContainerView.alpha = 0
            dataViewController.storyImage.alpha = 0
            dataViewController.isFinished = true
            dataViewController.author = story?.author ?? ""
            dataViewController.editor = story?.editor ?? ""
            dataViewController.illustrator = story?.illustrator ?? ""
            dataViewController.creativeDirector = story?.creativeDirector ?? ""
            
        }
        else {
            dataViewController.pageNumber = pages[index].pageNumber
            dataViewController.pageNumberString = pageNumbers[index]
            dataViewController.invisibleText = pages[index].pageText
            dataViewController.storyImage.image = pages[index].pageImage
        }
        return dataViewController
    }
    
    fileprivate func indexOfViewController(viewController: StoryContentController) -> Int {
        
        if let pageNumber: Int = viewController.pageNumber {
            return pageNumber - 1
        } else {
            return NSNotFound
        }
    }
    
}

extension StoryController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var index = indexOfViewController(viewController: viewController
            as! StoryContentController)
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return viewControllerAtIndex(index: index)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var index = indexOfViewController(viewController: viewController
            as! StoryContentController)
        
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        return viewControllerAtIndex(index: index)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            let numberOfControllers = (pageViewController.viewControllers?.count)! - 1
            let vc = pageViewController.viewControllers![numberOfControllers] as! StoryContentController
            vc.storyText = nextPageText
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let index = indexOfViewController(viewController: pendingViewControllers[0] as! StoryContentController)
        if index < pages.count {
            nextPageText = pages[index].pageText
        }
    }
   
    
    
}
