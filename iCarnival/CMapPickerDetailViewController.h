//
//  CMapPickerDetailViewController.h
//  iCarnival
//
//  Created by Nathanael Wallace on 1/21/14.
//  Copyright (c) 2014 Punahou School - Nathan Wallace '14. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMapViewController;

@interface CMapPickerDetailViewController : UITableViewController

@property (weak, nonatomic) CMapViewController *mapViewController;

- (void)setItems:(NSArray *)items;

@end
