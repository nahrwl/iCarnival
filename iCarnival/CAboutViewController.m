//
//  CAboutViewController.m
//  iCarnival
//
//  Created by Nathanael Wallace on 1/19/14.
//  Copyright (c) 2014 Punahou School - Nathan Wallace '14. All rights reserved.
//

#import "CAboutViewController.h"

@interface CAboutViewController ()

@end

@implementation CAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, 618)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)developersButton:(id)sender {
    static int count = 0;
    count++;
    
    if (count > 7) {
        count = 0;
        [self.imageView setImage:nil];
    }
    else if (count > 3) {
        // show the image
        [self.imageView setImage:[UIImage imageNamed:@"egg.png"]];
    }
}


@end
