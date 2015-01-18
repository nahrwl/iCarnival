//
//  CSocialTableViewController.m
//  iCarnival
//
//  Created by Nathan Wallace on 1/7/15.
//  Copyright (c) 2015 Punahou School - Nathan Wallace '14. All rights reserved.
//
//  Selected code from Twitter's sample code
//  https://dev.twitter.com/twitter-kit/ios/show-tweets

#import "CSocialTableViewController.h"

// ** FABRIC ** //
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>

static NSString * const kCellIdentifier = @"SocialCellIdentifier";
static NSString * const kPromptTwitterLoginKey = @"iCarnival-kPromptTwitterLoginKey";
static NSString * const kTwitterLoginTypeKey = @"iCarnival-kTwitterLoginTypeKey";

@interface CSocialTableViewController ()

@property (nonatomic, strong) NSArray *tweets;
// Just for height calculation purposes, never rendered on screen
@property (nonatomic, strong) TWTRTweetTableViewCell *prototypeCell;

- (void)checkFirstTimeLogIn;

- (void)refresh;
- (void)reloadTableViewWithTweets;

@end

@implementation CSocialTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup tableview
    self.tableView.estimatedRowHeight = 150;
    self.tableView.rowHeight = UITableViewAutomaticDimension; // Explicitly set on iOS 8 if using automatic row height calculation
    self.tableView.allowsSelection = NO;
    [self.tableView registerClass:
     [TWTRTweetTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    
    // Create a single prototype cell for height calculations
    self.prototypeCell = [[TWTRTweetTableViewCell alloc] init];
    
    [self checkFirstTimeLogIn];
    
}

- (void)checkFirstTimeLogIn
{
    // The first time the view appears, we need to ask the user if they want to log in.
    NSUserDefaults *stdUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL askLogin = ![stdUserDefaults boolForKey:kPromptTwitterLoginKey]; //! is because NO is default
    
    if (askLogin) {
        // Ask the user to log in
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login to Twitter"
                                                            message:@"If you have a Twitter account, please log in."
                                                           delegate:self
                                                  cancelButtonTitle:@"Not Now"
                                                  otherButtonTitles:@"Login", nil];
        [alertView show];
    } else {
        // User is not on the first time
        NSString *loginType = [stdUserDefaults stringForKey:kTwitterLoginTypeKey];
        // Access Twitter singleton
        Twitter *twtr = [Twitter sharedInstance];
        
        if ([loginType isEqualToString:@"Guest"]) {
            // User does not have Twitter, or else declined to sign in.
            if (![twtr guestSession]) {
                // If there's no preexisting guest session
                [twtr logInGuestWithCompletion:^(TWTRGuestSession *session, NSError *error) {
                    if (session) {
                        // make API calls that do not require user auth
                        NSLog(@"User successfully logged in as guest.");
                    } else {
                        NSLog(@"error: %@", [error localizedDescription]);
                    }
                }];
            }
            [self refresh];
        } else if ([loginType isEqualToString:@"User"]) {
            // User has signed in to Twitter in the past.
            if (![twtr session]) {
                // If there's no preexisting session
                [twtr logInWithCompletion:^(TWTRSession *session, NSError *error) {
                    if (session) {
                        NSLog(@"signed in as %@", [session userName]);
                    } else {
                        NSLog(@"error: %@", [error localizedDescription]);
                    }
                }];
            }
            [self refresh];
        } else {
            [stdUserDefaults setBool:NO forKey:kPromptTwitterLoginKey]; // No means YES - prompt the user next time
            NSLog(@"Error identifying login type. User not logged in.");
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUserDefaults *stdUserDefaults = [NSUserDefaults standardUserDefaults];
    
    // Assuming the alert is the login to twitter alert since thats the only alert
    if (buttonIndex == 0) {
        // Cancel
        [stdUserDefaults setObject:@"Guest" forKey:kTwitterLoginTypeKey];
        [stdUserDefaults setBool:YES forKey:kPromptTwitterLoginKey]; // YES means NO
        [self refresh];
    } else {
        // we home free!! Login to Twitter, baby.
        __weak typeof(self) weakSelf = self;
        [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
             if (session) {
                 NSLog(@"signed in as %@", [session userName]);
                 [stdUserDefaults setObject:@"User" forKey:kTwitterLoginTypeKey];
                 [stdUserDefaults setBool:YES forKey:kPromptTwitterLoginKey]; // YES means NO
             } else {
                 NSLog(@"error: %@", [error localizedDescription]);
                 // If we got rejected for some reason
                 // Attempt a guest login because I like nesting blocks
                 
                 // But actually wait on it because the guest login should happen only when it needs to
                 
                 [stdUserDefaults setObject:@"Guest" forKey:kTwitterLoginTypeKey];
                 [stdUserDefaults setBool:NO forKey:kPromptTwitterLoginKey]; // we want the user to be prompted to log in again next time because it failed for some reason
             }
            typeof(self) strongSelf = weakSelf;
            [strongSelf refresh];
         }];
    }
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
    // Return the number of rows in the section.
    return [self.tweets count];
}


- (TWTRTweetTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTRTweet *tweet = self.tweets[indexPath.row];
    
    TWTRTweetTableViewCell *cell = (TWTRTweetTableViewCell *)[tableView dequeueReusableCellWithIdentifier: kCellIdentifier forIndexPath:indexPath];
    [cell configureWithTweet:tweet];
    cell.tweetView.delegate = self;
    
    return cell;
}


- (void)refresh
{
    Twitter *twtr = [Twitter sharedInstance];
    
    if ([twtr session] || [twtr guestSession]) {
        // there's an existing session or guest session, so go ahead
        [self reloadTableViewWithTweets];
    }
    else
    {
        __weak typeof(self) weakSelf = self;
        [twtr logInGuestWithCompletion:^(TWTRGuestSession *session, NSError *error) {
             if (session) {
                 typeof(self) strongSelf = weakSelf;
                 
                 // Request #PunahouCarnival tweets
                 [strongSelf reloadTableViewWithTweets];

             } else {
                 NSLog(@"error: %@", [error localizedDescription]);
             }
         }];
    }
    
    
}

- (void)reloadTableViewWithTweets
{
    // Search for tweets
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/search/tweets.json";
    NSDictionary *params = @{@"q" : @"Punahou Carnival"};
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient]
                             URLRequestWithMethod:@"GET"
                             URL:statusesShowEndpoint
                             parameters:params
                             error:&clientError];
    
    __weak typeof(self) weakSelf = self;
    if (request) {
        [[[Twitter sharedInstance] APIClient]
         sendTwitterRequest:request
         completion:^(NSURLResponse *response,
                      NSData *data,
                      NSError *connectionError) {
             if (data) {
                 NSLog(@"Data: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                 // handle the response data e.g.
                 NSError *jsonError;
                 NSDictionary *jsonDic = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:0
                                  error:&jsonError];
                 
                 NSArray *json = [jsonDic objectForKey:@"statuses"];
                 
                 NSLog(@"Array: %@",json);
                 
                 if (json) {
                     NSArray *tweets = [TWTRTweet tweetsWithJSONArray:json];
                     if (tweets) {
                         typeof(self) strongSelf = weakSelf;
                         strongSelf.tweets = tweets;
                         [strongSelf.tableView reloadData];
                     } else {
                         NSLog(@"Failed to convert NSArray from JSON data to Tweets.");
                     }
                 } else {
                     NSLog(@"Failed to load tweets: %@",
                           [jsonError localizedDescription]);
                 }
             }
             else {
                 NSLog(@"Error: %@", connectionError);
             }
         }];
    }
    else {
        NSLog(@"Error: %@", clientError);
    }
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

// Calculate the height of each row
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTRTweet *tweet = self.tweets[indexPath.row];
    [self.prototypeCell configureWithTweet:tweet];
    
    return [self.prototypeCell calculatedHeightForWidth:
            CGRectGetWidth(self.view.bounds)];
}

# pragma mark - TWTRTweetViewDelegate Methods

- (UIViewController *)viewControllerForPresentation {
    return self;
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
