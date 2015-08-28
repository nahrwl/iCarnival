//
//  CTagboardViewController.h
//  iCarnival
//
//  Created by Nathan Wallace on 8/26/15.
//  Copyright © 2015 Punahou School - Nathan Wallace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface CTagboardViewController : UIViewController <WKNavigationDelegate>
@property (weak, nonatomic) IBOutlet UIView *mainView;

@end
