//
//  CWebViewController.h
//  iCarnival
//
//  Created by Nathan Wallace on 1/18/15.
//  Copyright (c) 2015 Punahou School - Nathan Wallace. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CWebViewController : UIViewController <UIActionSheetDelegate>
- (IBAction)segmentedControlChanged:(UISegmentedControl *)sender;

// Web view selectors
- (void)back;
- (void)forward;
- (void)open;

@end
