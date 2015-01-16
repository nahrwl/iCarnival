//
//  CSocialTableViewController.h
//  iCarnival
//
//  Created by Nathan Wallace on 1/7/15.
//  Copyright (c) 2015 Punahou School - Nathan Wallace '14. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSocialTableViewController : UITableViewController

- (IBAction)refreshTimeline;
- (IBAction)composeTweet;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *composeButton;

@end
