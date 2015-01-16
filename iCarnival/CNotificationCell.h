//
//  CNotificationCell.h
//  iCarnival
//
//  Created by Nathanael Wallace on 1/23/14.
//  Copyright (c) 2014 Punahou School - Nathan Wallace '14. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNotificationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
