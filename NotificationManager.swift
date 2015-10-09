//
//  NotificationManager.swift
//  hypebeast
//
//  Created by Felix Li on 4/9/15.
//  Copyright (c) 2015 42Labs. All rights reserved.
//

import Foundation

class NotificationManager{
    
    static let sharedInstance = NotificationManager()
    
    var userInfo: Dictionary<NSObject,AnyObject>!
    
    private init(){
        
    }
    
    func loadNotification(){
        
        if let notificationInfo = self.userInfo{
            
            var trackString = "notification "
            
            if let aps = notificationInfo["aps"] as? Dictionary<String, String>{

                if let alert = aps["alert"]{
                    trackString = trackString + "alert: \(alert) "
                }
            }
            
            if let articleURL = notificationInfo["link"] as? String{
                
                trackString = trackString + ", link: \(articleURL)"
                self.loadArticlePost(articleURL)
            }
            
            print (trackString)
            let tracker = GAI.sharedInstance().defaultTracker
            let event = GAIDictionaryBuilder.createEventWithCategory("notification_action" , action: "open_from_background", label: trackString, value: nil).build() as [NSObject : AnyObject]
            tracker.send(event)
            
            self.userInfo = nil
        }
    }
    
    private func loadArticlePost(articleURL: String){
        
        let trimmedArticleURL = articleURL.stringByReplacingOccurrencesOfString(" ", withString: "")

        API.checkPost(trimmedArticleURL, completionHandler: { (request, response, isPost, error) -> () in
            
            if error == nil && isPost{
                
                let navVC =  UIApplication.sharedApplication().keyWindow?.rootViewController as! UINavigationController
                navVC.popToRootViewControllerAnimated(false)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                // Init the PostItemViewController by Storyboard ID - PostItemViewController
                let vc = storyboard.instantiateViewControllerWithIdentifier("PostItemViewController") as! PostItemViewController
                
                vc.linkURLString = trimmedArticleURL
                
                // Nav Controller push the view controller
                navVC.pushViewController(vc, animated: true)
            }
        })
    }
}