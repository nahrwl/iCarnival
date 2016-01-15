//
//  CMessageSubmissionViewController.m
//  iCarnival
//
//  Created by Nathan Wallace on 1/14/16.
//  Copyright © 2016 Punahou School - Nathan Wallace. All rights reserved.
//

#import "CMessageSubmissionViewController.h"
#import <Parse/Parse.h>

@implementation CMessageSubmissionViewController

- (IBAction)buyButtonTapped:(UIButton *)sender {
    [PFPurchase buyProduct:kMessagePackProductIdentifier block:^(NSError *error) {
        NSLog(@"Purchase button tapped. Submission went through...");
        if (!error) {
            // Run UI logic that informs user the product has been purchased, such as displaying an alert view.
        } else {
            NSLog(@"Purchase Error: %@",[error localizedDescription]);
        }
    }];
}

@end
