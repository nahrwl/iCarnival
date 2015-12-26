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

@end

@implementation CWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    //config.applicationNameForUserAgent = @"iCarnival Punahou Carnival";
    self.wv = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    self.wv.navigationDelegate = self;
    WKUserContentController *userContentController = self.wv.configuration.userContentController;
    [userContentController addScriptMessageHandler:self name:@"notification"];
    
    self.wv.hidden = YES;
    
    self.wv.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.wv];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[wv]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{@"wv":self.wv}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[wv]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{@"wv":self.wv}]];
    
    //[self.wv.scrollView setContentInset:UIEdgeInsetsMake(20.0, 0, 50.0, 0)];
    
    [self.wv loadRequest:[NSURLRequest
                          requestWithURL:[NSURL URLWithString:@"https://tagboard.com/punahoucarnival/208630"]]];
    
}

- (IBAction)segmentedControlChanged:(UISegmentedControl *)sender {
    BOOL latest = sender.selectedSegmentIndex == 0 ? false : true;
    [self switchToLatest:latest];
}

- (void)switchToLatest:(BOOL)latest {
    NSString *idname;
    if (latest) {
        idname = @"latest";
    } else {
        idname = @"featured";
    }
    [self.wv evaluateJavaScript: [NSString stringWithFormat:@"this.tgb.state.switchState(jQuery('#%@-tab'));",idname]
              completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
                  NSLog(@"Switched to latest.");
              }];
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    static BOOL firstLoad = YES;
    if (firstLoad) {
        [self.wv evaluateJavaScript: @"jQuery('header').hide(); jQuery('footer').hide(); jQuery('#global-navbar').hide(); jQuery('.container-fluid.tb-wrapper').css('margin-top','20px'); $('#posts').on('tgb:featuredLoaded', function() { window.webkit.messageHandlers.notification.postMessage('complete'); });"
                  completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
                      NSLog(@"onLoad JS complete.");
                  }];
        firstLoad = NO;
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    static BOOL firstLoad = YES;
    if (firstLoad) {
        decisionHandler(WKNavigationActionPolicyAllow);
        firstLoad = NO;
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"JS console: %@",message.body);
    if ([message.body isEqualToString:@"complete"]) {
        self.wv.hidden = NO;
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
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

@end
