//
//  CNotificationsViewController.h
//  iCarnival
//
//  Created by Nathanael Wallace on 1/22/14.
//  Copyright (c) 2014 Punahou School - Nathan Wallace '14. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface CNotificationsViewController : PFQueryTableViewController <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *barSwitch;

- (IBAction)settingsButtonTapped:(id)sender;

- (void)updateNotifications;
- (void)shouldUpdateNotifications;

@end
