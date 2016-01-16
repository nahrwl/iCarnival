//
//  CMapViewController.h
//  iCarnival
//
//  Created by Nathanael Wallace on 1/19/14.
//  Copyright (c) 2014 Punahou School - Nathan Wallace '14. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface CMapViewController : UIViewController <MKMapViewDelegate, UIActionSheetDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchButtonItem;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *parkingButtonItem;

- (IBAction)searchButtonTapped:(id)sender;
- (void)doneButtonTapped;
- (IBAction)parkingButtonTapped:(id)sender;

- (IBAction)unwindToMap:(UIStoryboardSegue *)unwindSegue;

- (void)setSelectedItems:(NSArray *)items;

- (IBAction)locationButtonTapped:(UIButton *)sender;

@end
