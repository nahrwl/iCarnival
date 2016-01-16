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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
- (IBAction)retryButtonTapped:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *retryButton;

// Web view selectors
- (void)back;
- (void)forward;
- (void)open;

@end
