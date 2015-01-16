//
//  CMapPickerDetailViewController.m
//  iCarnival
//
//  Created by Nathanael Wallace on 1/21/14.
//  Copyright (c) 2014 Punahou School - Nathan Wallace '14. All rights reserved.
//

#import "CMapPickerDetailViewController.h"
#import "CMapItem.h"
#import "CMapViewController.h"

@interface CMapPickerDetailViewController ()

@property (strong, nonatomic) NSArray *items; // an array of cmapitems
@property (strong, nonatomic) NSArray *itemDisplayNames; // this is an array of strings

- (NSArray *)mapItems:(NSArray *)items forName:(NSString *)name;

@end

@implementation CMapPickerDetailViewController
@synthesize items = _items;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)items
{
    if (!_items) _items = [NSArray array];
    return _items;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) return 1;
    return self.itemDisplayNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    if (indexPath.section == 0) { cell.textLabel.text = @"Show All"; }
    else { cell.textLabel.text = self.itemDisplayNames[indexPath.row]; }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        // show all!
        [self.mapViewController setSelectedItems:self.items];
    }
    else if (indexPath.section == 1)
    {
        [self.mapViewController setSelectedItems:[self mapItems:self.items forName:self.itemDisplayNames[indexPath.row]]];
    }
}

- (NSArray *)mapItems:(NSArray *)items forName:(NSString *)name
{
    NSIndexSet *set = [items indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){
        return [[(CMapItem *)obj title] isEqualToString:name];
    }];
    return [items objectsAtIndexes:set];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}


- (void)setItems:(NSArray *)items
{
    _items = items;
    NSMutableArray *names = [[NSMutableArray alloc] init];
    for (CMapItem *item in items) {
        if (![names containsObject:item.title]) [names addObject:item.title];
    }
    self.itemDisplayNames = [names copy];
}


@end
