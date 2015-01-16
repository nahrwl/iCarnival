//
//  CMapPickerViewController.m
//  iCarnival
//
//  Created by Nathanael Wallace on 1/19/14.
//  Copyright (c) 2014 Punahou School - Nathan Wallace '14. All rights reserved.
//

#import "CMapPickerViewController.h"
#import "CMapItem.h"
#import "CMapPickerDetailViewController.h"
#import "CMapViewController.h"

@interface CMapPickerViewController ()

@property (strong, nonatomic) NSArray *mapItems;
@property (strong, nonatomic) NSArray *categories;

- (NSArray *)mapItems:(NSArray *)items forType:(CMapItemType)type;

@end

@implementation CMapPickerViewController
@synthesize mapItems = _mapItems;

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

    [self createCategories];
}

- (void)createCategories
{
    NSArray *tempArray = [[NSArray alloc] initWithObjects:@"Scrip",@"Ride Coupons",@"Restrooms",@"ATMs",@"Food",@"Rides",@"Games",@"Kiddieland",@"Booths",@"Emergency",@"Other",nil];
                          
    self.categories = tempArray;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setters and getters
- (NSArray *)mapItems
{
    if (!_mapItems) _mapItems = [NSArray array];
    return _mapItems;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    cell.textLabel.text = self.categories[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // First four objects should return directly
    switch (indexPath.row) {
        case 0:
            // scrip
            [self returnMapItemsForType:kScripType];
            break;
        case 1:
            // Ride coupons
            [self returnMapItemsForType:kRideCouponType];
            break;
        case 2:
            // Restrooms
            [self returnMapItemsForType:kBathroomType];
            break;
        case 3:
            // ATMs
            [self returnMapItemsForType:kATMType];
            break;
        case 4:
            // Food
            [self pushMapItemsForType:kFoodType];
            break;
        case 5:
            // Rides
            [self pushMapItemsForType:kRideType];
            break;
        case 6:
            // Games
            [self pushMapItemsForType:kGameType];
            break;
        case 7:
            // Kiddieland
            [self pushMapItemsForType:kKiddielandType];
            break;
        case 8:
            // Booths
            [self pushMapItemsForType:kBoothType];
            break;
        case 9:
            // Emergency
            [self pushMapItemsForType:kEmergencyType];
            break;
        case 10:
            // Other
            [self pushMapItemsForType:kOtherType];
            break;
    }

    
}

- (void)returnMapItemsForType:(CMapItemType)type
{
    [self.mapViewController setSelectedItems:[self mapItems:self.mapItems forType:type]];
}

- (void)pushMapItemsForType:(CMapItemType)type
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle:[NSBundle mainBundle]];
    CMapPickerDetailViewController *mpvc = (CMapPickerDetailViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"detailMapItem"];
    [mpvc setItems:[self mapItems:self.mapItems forType:type]];
    mpvc.mapViewController = self.mapViewController;
    mpvc.navigationItem.title = [CMapItem stringFromType:type];
    
    [self.navigationController pushViewController:mpvc animated:YES];
}

- (NSArray *)mapItems:(NSArray *)items forType:(CMapItemType)type
{
    NSIndexSet *set = [items indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){
        return [(CMapItem *)obj itemType] == type;
    }];
    return [items objectsAtIndexes:set];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"cancelSearch"])
    {
        
    }
}

- (void)setMapItems:(NSArray *)items
{
    _mapItems = items;
}



@end
