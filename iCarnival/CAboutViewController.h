//
//  CAboutViewController.h
//  iCarnival
//
//  Created by Nathanael Wallace on 1/19/14.
//  Copyright (c) 2014 Punahou School - Nathan Wallace '14. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CAboutViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)developersButton:(id)sender;

@end
