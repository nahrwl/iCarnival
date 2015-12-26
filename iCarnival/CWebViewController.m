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
    
    // Load the Tagboard content
    //[self.webView loadHTMLString:@"<html><body><div class=\"tagboard-embed\" tgb-slug=\"punahoucarnival/208630\" tgb-layout=\"waterfall\" tgb-feed-type=\"default\" tgb-toolbar=\"none\" tgb-animation-type=\"default\"></div><script src=\"https://tagboard.com/public/js/embedAdvanced.js\"></script></body></html>" baseURL:[NSURL URLWithString:@""]];
    //[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://tagboard.com/punahoucarnival/208630#at=default&tb=none&ft=default&id=1"]]];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.applicationNameForUserAgent = @"iCarnival Punahou Carnival";
    self.wv = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    self.wv.navigationDelegate = self;
    WKUserContentController *userContentController = self.wv.configuration.userContentController;
    [userContentController addScriptMessageHandler:self name:@"notification"];
    
    self.wv.hidden = YES;
    
    self.wv.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.wv];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[wv]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{@"wv":self.wv}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[wv]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{@"wv":self.wv}]];
    
    [self.wv loadRequest:[NSURLRequest
                          requestWithURL:[NSURL URLWithString:@"https://tagboard.com/punahoucarnival/208630"]]];
    
}

- (void)switchToLatest {
    /*[self.wv evaluateJavaScript: @"alert('test'); jQuery(this.tgb.$container).on('tgb:featuredLoaded', function() { this.tgb.state.switchState(jQuery('#latest-tab')); });"
              completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
                  NSLog(@"onLoad JS complete.");
              }];*/
    [self.wv evaluateJavaScript: @"this.tgb.state.switchState(jQuery('#latest-tab'));"
              completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
                  NSLog(@"Switched to latest.");
              }];

}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    static BOOL firstLoad = YES;
    if (firstLoad) {
        [self.wv evaluateJavaScript: @"jQuery('header').children().hide(); jQuery('footer').hide(); $('#posts').on('tgb:featuredLoaded', function() { window.webkit.messageHandlers.notification.postMessage('complete'); tgb.state.switchState(jQuery('#latest-tab')); });"
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
