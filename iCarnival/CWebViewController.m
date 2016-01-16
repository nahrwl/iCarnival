//
//  CWebViewController.m
//  iCarnival
//
//  Created by Nathan Wallace on 1/18/15.
//  Copyright (c) 2015 Punahou School - Nathan Wallace. All rights reserved.
//

#import "CWebViewController.h"
@import WebKit;

@interface CWebViewController () <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>

@property (strong, nonatomic) WKWebView *wv;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic) CGPoint featuredOffset;
@property (nonatomic) CGPoint latestOffset;

@property (strong, nonatomic) WKNavigation *currentNavigation;

@end

@implementation CWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.segmentedControl.hidden = YES;
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.suppressesIncrementalRendering = YES;
    //config.applicationNameForUserAgent = @"iCarnival Punahou Carnival";
    
    // Add CSS styles to the config
    NSString *bodyScriptContent = @"var styleTag = document.createElement(\"style\"); styleTag.textContent = 'body {display:none;}'; document.documentElement.appendChild(styleTag);";
    WKUserScript *bodyScript = [[WKUserScript alloc] initWithSource:bodyScriptContent injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    [config.userContentController addUserScript:bodyScript];
    
    NSString *scriptContent = @"var styleTag = document.createElement(\"style\"); styleTag.textContent = 'header, footer, #global-navbar {display:none;} .container-fluid.tb-wrapper {margin-top: 20px;}'; document.documentElement.appendChild(styleTag);";
    WKUserScript *script = [[WKUserScript alloc] initWithSource:scriptContent injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [config.userContentController addUserScript:script];
    
    self.wv = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    self.wv.navigationDelegate = self;
    WKUserContentController *userContentController = self.wv.configuration.userContentController;
    [userContentController addScriptMessageHandler:self name:@"notification"];
    
    // Add refresh control to web view
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    // The refresh control is not added as a subview until the first page load is complete
    
    self.wv.hidden = YES;
    
    self.wv.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.wv];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[wv]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{@"wv":self.wv}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[wv]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{@"wv":self.wv}]];
    
    [self.wv.scrollView setContentInset:UIEdgeInsetsMake(64.0, 0, 50.0, 0)];
    [self.wv.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(64.0, 0, 50.0, 0)];
    
    self.wv.scrollView.maximumZoomScale = 1.0;
    self.wv.scrollView.minimumZoomScale = 1.0;
    
    self.featuredOffset = CGPointMake(0.0, -64.0);
    self.latestOffset = CGPointMake(0.0, -64.0);
    
    self.currentNavigation = [self.wv loadRequest:[NSURLRequest
                          requestWithURL:[NSURL URLWithString:@"https://tagboard.com/punahoucarnival/208630"]]];
    
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    //refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating #PunahouCarnival"];
    
    self.currentNavigation = [self.wv reload];
    
    // Reset relevant variables
    self.featuredOffset = CGPointMake(0.0, -64.0);
    self.latestOffset = CGPointMake(0.0, -64.0);
    
    // Quickly hide the web view
    [UIView animateWithDuration:0.5 animations:^{
        //self.wv.layer.opacity = 0;
    } completion:^(BOOL finished) {
        // Nothing right now
        //self.wv.hidden = YES;
    }];
}

- (IBAction)segmentedControlChanged:(UISegmentedControl *)sender {
    BOOL latest = sender.selectedSegmentIndex == 0 ? NO : YES;
    [self switchToLatest:latest];
}

- (void)switchToLatest:(BOOL)latest {
    [UIView animateWithDuration:0.5 animations:^{
        self.wv.layer.opacity = 0.0;
    } completion:^(BOOL finished) {
        NSString *idname;
        if (latest) {
            idname = @"latest";
            
            self.featuredOffset = self.wv.scrollView.contentOffset;
            [self.wv.scrollView setContentOffset:self.latestOffset];
            
        } else {
            idname = @"featured";
            
            self.latestOffset = self.wv.scrollView.contentOffset;
            [self.wv.scrollView setContentOffset:self.featuredOffset];
        }
        [self.wv evaluateJavaScript: [NSString stringWithFormat:@"this.tgb.state.switchState(jQuery('#%@-tab'));",idname]
                  completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
                      NSLog(@"Switched to latest.");
                      
                      [UIView animateWithDuration:0.5 delay:0.35 options:UIViewAnimationOptionTransitionNone animations:^{
                          self.wv.layer.opacity = 1.0;
                      } completion:nil];
                  }];
    }];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if ([self.currentNavigation isEqual:navigation]) {
        // End refreshing (if necessary)
        [self.refreshControl endRefreshing];
        
        // Clean up the page
        /*[self.wv evaluateJavaScript: @"jQuery('header').hide(); jQuery('footer').hide(); jQuery('#global-navbar').hide(); jQuery('.container-fluid.tb-wrapper').css('margin-top','20px'); $('#posts').on('tgb:featuredLoaded', function() { window.webkit.messageHandlers.notification.postMessage('complete'); jQuery('.owned').unbind('click'); });"
                  completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
                      NSLog(@"onLoad JS complete.");
                  }];*/
        [self.wv evaluateJavaScript: @"jQuery('body').show(); $('#posts').on('tgb:featuredLoaded', function() { window.webkit.messageHandlers.notification.postMessage('complete'); jQuery('.owned').unbind('click'); });"
                  completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
                      NSLog(@"onLoad JS complete.");
                  }];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    static BOOL firstLoad = YES;
    if (firstLoad || navigationAction.navigationType == WKNavigationTypeReload) {
        decisionHandler(WKNavigationActionPolicyAllow);
        firstLoad = NO;
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"JS console: %@",message.body);
    if ([message.body isEqualToString:@"complete"]) {
        
        // Animate out the loading views
        [UIView animateWithDuration:1.0 animations:^{
            self.activityIndicator.layer.opacity = 0.0;
            self.loadingLabel.layer.opacity = 0.0;
        } completion:^(BOOL finished) {
            [self.activityIndicator stopAnimating];
            self.loadingLabel.hidden = YES;
        }];
        
        
        // Animate the web view and segmented control in,
        self.wv.hidden = NO;
        self.wv.layer.opacity = 0.0;
        
        self.segmentedControl.layer.opacity = 0.0;
        self.segmentedControl.userInteractionEnabled = NO;
        self.segmentedControl.hidden = NO;

        [UIView animateWithDuration:1.0 delay:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
            self.segmentedControl.layer.opacity = 1.0;
            self.wv.layer.opacity = 1.0;
        } completion:^(BOOL finished) {
            self.segmentedControl.userInteractionEnabled = YES;
            // Add in the refresh control
            [self.wv.scrollView addSubview:self.refreshControl];
        }];
    }
}

- (void)back
{
    NSLog(@"back");
    
}

- (void)forward
{
    NSLog(@"forward");
    
}

- (void)open
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Open in Safari",nil];
    [actionSheet showInView:self.view];
    
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.webView.request.URL.absoluteString]];
    }
}

#pragma mark - Delegate

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        //[[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

@end
