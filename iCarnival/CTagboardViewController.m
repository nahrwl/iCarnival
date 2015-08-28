//
//  CTagboardViewController.m
//  iCarnival
//
//  Created by Nathan Wallace on 8/26/15.
//  Copyright © 2015 Punahou School - Nathan Wallace. All rights reserved.
//

#import "CTagboardViewController.h"

@interface CTagboardViewController ()

@property (weak, nonatomic) WKWebView *wView;

@end

@implementation CTagboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.allowsInlineMediaPlayback = YES;
    config.mediaPlaybackRequiresUserAction = NO;
    config.mediaPlaybackAllowsAirPlay = NO;
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:config];
    
    webView.navigationDelegate = self;
    
    //webView.scrollView.contentInset = UIEdgeInsetsMake(64, 0, 50, 0);
    
    webView.backgroundColor = [UIColor redColor];
    
    [self.mainView addSubview:webView];
    self.wView = webView;
    
    
    //[webView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:NSLayoutFormatAlignAllLeft metrics:nil views:@{@"webView" : webView}]];
    //[webView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|" options:NSLayoutFormatAlignAllLeft metrics:nil views:@{@"webView" : webView}]];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    NSURL *url = [NSURL URLWithString:@"http://www.google.com/"];
    if (url) {
        [self.wView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
