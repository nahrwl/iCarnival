//
//  CTagboardViewController.m
//  iCarnival
//
//  Created by Nathan Wallace on 8/26/15.
//  Copyright © 2015 Punahou School - Nathan Wallace. All rights reserved.
//

#import "CTagboardViewController.h"
#import <WebKit/WebKit.h>

@interface CTagboardViewController ()

@property (strong, nonatomic) WKWebView *webView;

@end

@implementation CTagboardViewController

- (void)awakeFromNib {
    [super awakeFromNib];

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.allowsInlineMediaPlayback = YES;
    config.mediaPlaybackRequiresUserAction = NO;
    config.mediaPlaybackAllowsAirPlay = NO;
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) configuration:config];
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(64, 0, 50, 0);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURL *url = [NSURL URLWithString:@"http://www.cnn.com"];
    if (url) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
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
