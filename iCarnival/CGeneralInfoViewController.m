//
//  CGeneralInfoViewController.m
//  iCarnival
//
//  Created by Nathanael Wallace on 1/18/14.
//  Copyright (c) 2014 Punahou School - Nathan Wallace '14. All rights reserved.
//

#import "CGeneralInfoViewController.h"

#define kNumberOfPages 2
#define kPageStoryboardID @"ViewController1_"

@interface CGeneralInfoViewController () {
    int _index;
}

@property (strong, nonatomic, readwrite) NSArray *pageViewControllers;

@end

@implementation CGeneralInfoViewController

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
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    
    // Find all the view controllers in the storyboard that should become pages
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithCapacity:kNumberOfPages];
    for (int i = 0; i < kNumberOfPages; i++)
    {
        [viewControllers addObject:[storyboard instantiateViewControllerWithIdentifier:[kPageStoryboardID stringByAppendingString:[NSString stringWithFormat:@"%d",i]]]];
    }
    
    [self setPageViewControllers:[viewControllers copy]];
    
    self.dataSource = self;
    self.delegate = self;
    
    _index = 0;
    [self setViewControllers:[NSArray arrayWithObject:[self.pageViewControllers objectAtIndex:_index]]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.pageViewControllers indexOfObjectIdenticalTo:viewController];
    if (index > 0) {
        return [self.pageViewControllers objectAtIndex:(index - 1)];
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.pageViewControllers indexOfObjectIdenticalTo:viewController];
    if (index + 1 < self.pageViewControllers.count) {
        return [self.pageViewControllers objectAtIndex:(index + 1)];
    }
    return nil;
}
/*
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    int result = self.pageViewControllers.count;
    return result;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return _index;
}
*/

#pragma mark - Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed && previousViewControllers.count > 0 && pageViewController.viewControllers.count > 0)
    {
        UIViewController *oldVC = [previousViewControllers objectAtIndex:0];
        UIViewController *newVC = [[pageViewController viewControllers] objectAtIndex:0];
        
        _index = _index + ([self.pageViewControllers indexOfObjectIdenticalTo:newVC] - [self.pageViewControllers indexOfObjectIdenticalTo:oldVC]);
        
        self.segmentedControl.selectedSegmentIndex = _index;
    }
}

#pragma mark - IB

- (IBAction)segmentedControlTapped:(id)sender
{
    if (self.segmentedControl.selectedSegmentIndex > _index) {
        // go to new page with forward animation
        _index = self.segmentedControl.selectedSegmentIndex;
        [self setViewControllers:[NSArray arrayWithObject:self.pageViewControllers[_index]]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:YES
                      completion:nil];
    } else if (self.segmentedControl.selectedSegmentIndex < _index) {
        // go backwards
        _index = self.segmentedControl.selectedSegmentIndex;
        [self setViewControllers:[NSArray arrayWithObject:self.pageViewControllers[_index]]
                       direction:UIPageViewControllerNavigationDirectionReverse
                        animated:YES
                      completion:nil];
    }
}

@end
