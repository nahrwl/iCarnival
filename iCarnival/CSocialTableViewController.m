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
#import "CWebViewController.h"

// ** FABRIC ** //
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>

// ** PARSE ** //
#import <Parse/Parse.h>

// Constants //
#define kParseAPIMinWaitInterval (NSTimeInterval)15.0
#define kParseAPITweetLimit 30

static NSString * const kCellIdentifier = @"SocialCellIdentifier";
static NSString * const kPromptTwitterLoginKey = @"iCarnival-kPromptTwitterLoginKey";
static NSString * const kTwitterLoginTypeKey = @"iCarnival-kTwitterLoginTypeKey";

static NSString * const kLastUpdatedKey = @"iCarnival-kLastUpdatedKey"; // ALSO CHANGE IN APP DELEGATE

@interface CSocialTableViewController ()

@property (nonatomic, strong) NSArray *tweets;
// Just for height calculation purposes, never rendered on screen
@property (nonatomic, strong) TWTRTweetTableViewCell *prototypeCell;

@property (nonatomic, strong) NSDate *lastParseAPICall;

- (void)checkFirstTimeLogIn;

- (void)refresh;
- (void)reloadTableViewWithTweets;

- (void)displayWebViewWithURL:(NSURL *)url;



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
    
    // Setup refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor colorWithRed:0.72549 green:0.63137 blue:0.27843 alpha:1.0];
    self.refreshControl = refreshControl;
    
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
            [stdUserDefaults synchronize];
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
        [stdUserDefaults synchronize];
        [self refresh];
    } else {
        // we home free!! Login to Twitter, baby.
        __weak typeof(self) weakSelf = self;
        [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
             if (session) {
                 NSLog(@"signed in as %@", [session userName]);
                 [stdUserDefaults setObject:@"User" forKey:kTwitterLoginTypeKey];
                 [stdUserDefaults setBool:YES forKey:kPromptTwitterLoginKey]; // YES means NO
                 [stdUserDefaults synchronize];
             } else {
                 NSLog(@"error: %@", [error localizedDescription]);
                 // If we got rejected for some reason
                 // Attempt a guest login because I like nesting blocks
                 
                 // But actually wait on it because the guest login should happen only when it needs to
                 
                 [stdUserDefaults setObject:@"Guest" forKey:kTwitterLoginTypeKey];
                 [stdUserDefaults setBool:NO forKey:kPromptTwitterLoginKey]; // we want the user to be prompted to log in again next time because it failed for some reason
                 [stdUserDefaults synchronize];
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
    NSLog(@"Refresh called. Initiating API call.");
    
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
    //If there is no record of a last api call, set an arbitrary date in the past
    if (!self.lastParseAPICall) self.lastParseAPICall = [NSDate distantPast];
    
    //Don't make API requests too fast
    if ([[NSDate date] timeIntervalSinceDate:self.lastParseAPICall] > kParseAPIMinWaitInterval) {
        
        // Request list of approved tweet IDs from Parse
        
        PFQuery *query = [PFQuery queryWithClassName:@"tweets"];
        query.limit = kParseAPITweetLimit;
        
        __weak typeof(self) weakSelf = self;
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            // Retrieve IDs from returned data
            NSMutableArray *idArray = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            for (PFObject *object in objects) {
                NSString *tid = object[@"tweetID"];
                [idArray addObject:tid];
            }
            
            // Retrieve tweets using list of IDs
            [[[Twitter sharedInstance] APIClient] loadTweetsWithIDs:[idArray copy] completion:^(NSArray *tweets, NSError *error) {
                if (tweets) {
                    // Update the table view
                    typeof(self) strongSelf = weakSelf;
                    strongSelf.tweets = tweets;
                    [strongSelf.tableView reloadData];
                } else {
                    NSLog(@"Failed to load tweet: %@", [error localizedDescription]);
                }
                
                [self.refreshControl endRefreshing];
            }];
        }];
        
        self.lastParseAPICall = [NSDate date];
    } else {
        // Do nothing - don't update the table view
        // End refreshing
        [self.refreshControl endRefreshing];
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
             if (![[[NSUserDefaults standardUserDefaults] stringForKey:kTwitterLoginTypeKey] isEqualToString:@"User"]) {
                 [[NSUserDefaults standardUserDefaults] setObject:@"User" forKey:kTwitterLoginTypeKey];
             }
             TWTRComposer *composer = [[TWTRComposer alloc] init];
             
             [composer setText:@"#PunahouCarnival "];
             
             [composer showWithCompletion:^(TWTRComposerResult result) {
                 if (result == TWTRComposerResultCancelled) {
                     NSLog(@"Tweet composition cancelled");
                 }
                 else {
                     NSLog(@"Sending Tweet!");
                 }
             }];
         } else {
             NSLog(@"error: %@", [error localizedDescription]);
         }
     }];
}

// Calculate the height of each row
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTRTweet *tweet = self.tweets[indexPath.row];
    [self.prototypeCell configureWithTweet:tweet];
    
    return [TWTRTweetTableViewCell heightForTweet:tweet width:CGRectGetWidth(self.view.bounds)];
}

# pragma mark - TWTRTweetViewDelegate Methods

- (UIViewController *)viewControllerForPresentation {
    return self;
}

- (void)tweetView:(TWTRTweetView *)tweetView
   didSelectTweet:(TWTRTweet *)tweet {
    NSLog(@"log in my app that user selected tweet");
    //[self displayWebViewWithURL:tweet.permalink];
}

- (void)tweetView:(TWTRTweetView *)tweetView didTapURL:(NSURL *)url {
    // Open your own custom webview
    
    // *or* Use a system webview
    NSLog(@"User tapped URL.");
    //[self displayWebViewWithURL:url];
    
    [[UIApplication sharedApplication] openURL:url];
}

- (void)displayWebViewWithURL:(NSURL *)url
{
    CWebViewController *webViewController = [[CWebViewController alloc] init];
    UIWebView *webView = [[UIWebView alloc]
                          initWithFrame:webViewController.view.bounds];
    [webView loadRequest:[NSURLRequest
                          requestWithURL:url]];
    webViewController.view = webView;
    webViewController.webView = webView; // just because I can and its convenient.
    
    //UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:webViewController action:@selector(back)];
    //UIBarButtonItem *forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forward"] style:UIBarButtonItemStylePlain target:webViewController action:@selector(forward)];
    
    //webViewController.navigationItem.rightBarButtonItems = @[forwardButton, backButton];
    
    UIBarButtonItem *openButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:webViewController action:@selector(open)];
    
    webViewController.navigationItem.rightBarButtonItem = openButton;
    
    webView.delegate = webViewController;
    
    [self.navigationController pushViewController:
     webViewController animated:YES];
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
