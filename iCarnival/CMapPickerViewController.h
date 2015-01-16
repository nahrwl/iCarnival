//
//  CMapPickerViewController.h
//  iCarnival
//
//  Created by Nathanael Wallace on 1/19/14.
//  Copyright (c) 2014 Punahou School - Nathan Wallace '14. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMapViewController;

@interface CMapPickerViewController : UITableViewController

@property (weak, nonatomic) CMapViewController *mapViewController;

- (void)setMapItems:(NSArray *)items;

@end
