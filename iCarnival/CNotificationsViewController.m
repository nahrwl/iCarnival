//
//  CNotificationsViewController.m
//  iCarnival
//
//  Created by Nathanael Wallace on 1/22/14.
//  Copyright (c) 2014 Punahou School - Nathan Wallace '14. All rights reserved.
//

#import "CNotificationsViewController.h"
#import "CNotificationCenter.h"
#import "CNotificationCell.h"

#define kCellWidth 300.0
#define kCellPadding 30.0
#define kMinCellHeight 75.0
#define kNormalCellHeight 75.0

static NSString *kNotificationsOnKey = @"iCarnival_kNotificationsOnKey";

@interface CNotificationsViewController ()

@property (nonatomic) BOOL notificationsOn;
@property (nonatomic) BOOL needsReload;
@property (nonatomic) int width;

@end

@implementation CNotificationsViewController

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        // Customize the table
        
        // The className to query on
        self.parseClassName = @"soundbooth";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"alert";
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
        // self.imageKey = @"image";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 25;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.width = 0;
    int size = self.view.frame.size.width;
    if (size > 413) {
        self.width = 2;
    } else if (size > 320) {
        self.width = 1;
    }

    /*NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *onValue = [defaults objectForKey:kNotificationsOnKey];
    if (!onValue) {
        onValue = [NSNumber numberWithBool:NO];
    }
    self.notificationsOn = [onValue boolValue];*/
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if (types != UIRemoteNotificationTypeNone) {
        _notificationsOn = YES;
    } else {
        _notificationsOn = NO;
    }
    [self.barSwitch setOn:self.notificationsOn];
    
    if (self.needsReload) {
        // reload data
        [self loadObjects];
        self.needsReload = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNotificationsOn:(BOOL)notificationsOn
{
    if (!notificationsOn) {
        // turn off notifications
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Push Disabled"
                                                        message:@"Notifications have been disabled."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        // turn notifications on
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
         UIRemoteNotificationTypeAlert|
         UIRemoteNotificationTypeSound];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Push Enabled"
                                                        message:@"Notifications have been enabled."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    _notificationsOn = notificationsOn;
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    // Return the number of rows in the section.
//    return [[[CNotificationCenter sharedNotificationCenter] notificationsForChannel:@"soundbooth"] count];
//}
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float cellWidth = kCellWidth;
    if (self.width == 1) {
        cellWidth = kCellWidth + 35.0;
    } else if (self.width == 2) {
        cellWidth = kCellWidth + 100.0;
    }
    
    float cellPadding = kCellPadding;
    if (self.width == 1) {
        cellPadding = kCellPadding + 10.0;
    } else if (self.width == 2) {
        cellPadding = kCellPadding + 10.0;
    }
    
    PFObject *obj = [self objectAtIndexPath:indexPath];
    NSString *notification = [obj objectForKey:self.textKey];
    if (notification)
    {
        NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithCapacity:2];
        [attributes setObject:[UIFont systemFontOfSize:18.0f] forKey:NSFontAttributeName];
        
        NSShadow *shadow = [[NSShadow alloc] init];
        [shadow setShadowOffset:CGSizeMake(0, -1)];
        [attributes setObject:shadow forKey:NSShadowAttributeName];
        
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        [context setMinimumScaleFactor:0.0];
        
        CGRect bounds = [notification boundingRectWithSize:CGSizeMake(cellWidth, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:context];
        
        CGFloat height = bounds.size.height;
        CGFloat roundedHeight = ceilf(height);
        CGFloat textHeight = roundedHeight + cellPadding;
        
        //CGFloat textHeight = ceil(bounds.size.height) + kCellPadding;
        if (textHeight < kMinCellHeight) textHeight = kMinCellHeight;
        
        return textHeight;
    }
    return kNormalCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    
    CNotificationCell *cell = (CNotificationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    cell.titleLabel.text = [object objectForKey:self.textKey];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSDate *date  = object.createdAt;
    
    cell.dateLabel.text = [dateFormatter stringFromDate:date];
    
    return cell;
}

- (void)updateNotifications
{
    [self loadObjects];
}

- (void)shouldUpdateNotifications
{
    self.needsReload = YES;
}
//
///*
//// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}
//*/
//
///*
//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }   
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
//}
//*/
//
///*
//// Override to support rearranging the table view.
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
//{
//}
//*/
//
///*
//// Override to support conditional rearranging of the table view.
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the item to be re-orderable.
//    return YES;
//}
//*/
//
///*
//#pragma mark - Navigation
//
//// In a story board-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}
//
// */

- (IBAction)switchValueChanged:(id)sender {
    if (self.barSwitch.on) {
        self.notificationsOn = YES;
    } else {
        self.notificationsOn = NO;
    }
}
@end
