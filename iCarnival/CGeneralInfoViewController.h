//
//  CGeneralInfoViewController.h
//  iCarnival
//
//  Created by Nathanael Wallace on 1/18/14.
//  Copyright (c) 2014 Punahou School - Nathan Wallace '14. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CGeneralInfoViewController : UIPageViewController< UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)segmentedControlTapped:(id)sender;

@end
