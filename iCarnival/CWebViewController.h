//
//  CWebViewController.h
//  iCarnival
//
//  Created by Nathan Wallace on 1/18/15.
//  Copyright (c) 2015 Punahou School - Nathan Wallace. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CWebViewController : UIViewController

@property (weak, nonatomic) UIWebView *webView;

// Web view selectors
- (void)back;
- (void)forward;

@end
