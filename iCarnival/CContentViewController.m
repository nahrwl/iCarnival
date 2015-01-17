//
//  CContentViewController.m
//  iCarnival
//
//  Created by Nathanael Wallace on 1/18/14.
//  Copyright (c) 2014 Punahou School - Nathan Wallace '14. All rights reserved.
//

#import "CContentViewController.h"

@interface CContentViewController ()

@property (nonatomic) int _position;

@end

@implementation CContentViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cool-print"]]];
    self._position = 84;
    int size = self.view.frame.size.width;
    if (size > 320) self._position = 104;
    
    self.tableView.delegate = self;
    
    //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    //[self.tableView setContentOffset:CGPointZero animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)unwindToInfoView:(UIStoryboardSegue *)unwindSegue
{
    // stuff happens here I guess
    // this is used in the storyboard, don't touch this even though there's not code here!
}

#pragma mark - Scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // This section is sort of an easter egg
    // Reveals art behind the scrollview when the
    // scrollview goes all the way to the top.
    
    int position = __position;
    
    //NSLog(@"Scroll view scrolled!");
    float scrollOffset = scrollView.contentOffset.y;
    if (scrollOffset < -position)
    {
        float opacity = 1.0 + ((scrollOffset + position) / 30.0); //scrollOffset should be neg
        opacity = (opacity > 0) ? opacity : 0;
        self.tableView.opaque = YES;
        self.tableView.alpha = opacity;
        self.tabBarController.tabBar.alpha = opacity;
        self.navigationController.navigationBar.alpha = opacity;
    } else if (scrollOffset < 0) {
        self.tableView.alpha = 1.0;
        self.tableView.opaque = YES;
        self.tabBarController.tabBar.alpha = 1.0;
        self.navigationController.navigationBar.alpha = 1.0;
    }
}


@end
