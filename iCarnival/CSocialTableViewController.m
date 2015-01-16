//
//  CSocialTableViewController.m
//  iCarnival
//
//  Created by Nathan Wallace on 1/7/15.
//  Copyright (c) 2015 Punahou School - Nathan Wallace '14. All rights reserved.
//

#import "CSocialTableViewController.h"

// ** FABRIC ** //
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>

@interface CSocialTableViewController ()

- (void)refresh;

@end

@implementation CSocialTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

- (void)refresh
{
    [[Twitter sharedInstance] logInGuestWithCompletion:^
     (TWTRGuestSession *session, NSError *error) {
         if (session) {
             // Request #PunahouCarnival tweets
             
         } else {
             NSLog(@"error: %@", [error localizedDescription]);
         }
     }];
}

- (IBAction)refreshTimeline
{
    [self refresh];
}

- (IBAction)composeTweet
{
    [[Twitter sharedInstance] logInWithCompletion:^
     (TWTRSession *session, NSError *error) {
         if (session) {
             NSLog(@"signed in as %@", [session userName]);
         } else {
             NSLog(@"error: %@", [error localizedDescription]);
         }
     }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
