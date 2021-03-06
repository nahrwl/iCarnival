//
//  CMapViewController.m
//  iCarnival
//
//  Created by Nathanael Wallace on 1/19/14.
//  Copyright (c) 2014 Punahou School - Nathan Wallace '14. All rights reserved.
//

#import <Parse/Parse.h>

#import "CMapViewController.h"
#import "CMapPickerViewController.h"
#import "CMapItem.h"

@interface CMapViewController () {
    BOOL parkingSaved;
}

@property (strong, nonatomic) UIBarButtonItem *rightButtonItem;
@property (nonatomic) BOOL isSearching;

@property (strong, nonatomic, readwrite) NSArray *mapItems;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D parkingCoordinates;
@property (strong, nonatomic) MKPointAnnotation *parkingAnnotation;

//for location finding purposes
@property (strong, nonatomic) CLLocation *bestLocation;

//to continue to display an error message after didChangeAuthorizationStatus does it the first time
@property (nonatomic) BOOL displayLocationError;

- (NSArray *)mapItemsFromPlistInBundle:(NSString *)nameInBundle;
- (NSArray *)mapItemsFromPFObjects:(NSArray *)objectsArray;
- (void)dropPinsForMapItems:(NSArray *)items;
- (void)saveCurrentLocation:(CLLocationCoordinate2D)coordinate;
- (void)cancelLocationUpdates;
- (void)stopUpdatingLocation;

- (UIBarButtonItem *)createParkingButtonItem;

@end

static NSString *kLatitudeKey = @"iCarnival_kLatitudeKey";
static NSString *kLongitudeKey = @"iCarnival_kLongitudeKey";

@implementation CMapViewController

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
    
    [self setMapRegionToPunahou];
    
    // load saved parking space from NSUserDefaults, if necessary
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CLLocationDegrees latitude = [(NSNumber *)[defaults objectForKey:kLatitudeKey] doubleValue];
    CLLocationDegrees longitude = [(NSNumber *)[defaults objectForKey:kLongitudeKey] doubleValue];
    if (latitude && longitude) {
        self.parkingCoordinates = CLLocationCoordinate2DMake(latitude, longitude);
        parkingSaved = YES;
    } else {
        parkingSaved = NO;
    }
    
    self.bestLocation = nil;
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"map"];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // Results were successfully found, looking first on the
            // cache and then on the network.

            self.mapItems = [self mapItemsFromPFObjects:objects];
            [self dropPinsForMapItems:self.mapItems];
        } else {
            // The network was inaccessible and we have no cached data for
            // this query.
            
            // Load the old map
            self.mapItems = [self mapItemsFromPlistInBundle:@"items"];
            [self dropPinsForMapItems:self.mapItems];
        }
    }];
    
    // ask for permission
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (void)setMapRegionToPunahou
{
    MKCoordinateRegion region;
	MKCoordinateSpan span;
    span.latitudeDelta=0.0017315 * sinf(35*3.14159/180);
    span.longitudeDelta=0.005668 * sinf(35*3.14159/180);
    
    region.span=span;
    //latitude , 21.303145 longitude  -157.831074
	region.center.latitude=21.303145;
    region.center.longitude=-157.830574;
    [self.mapView setRegion:region animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters and setters

- (NSArray *)mapItems
{
    if (!_mapItems) {
        _mapItems = [NSArray array];
        NSLog(@"Shouldn't the mapItems array be previously loaded from the bundle?");
    }
    return  _mapItems;
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    }
    return _locationManager;
}

- (void)setIsSearching:(BOOL)isSearching
{
    if (isSearching)
    {
        // set the right button item to say "Done"
        self.rightButtonItem = self.searchButtonItem;
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped)];
        button.tintColor = [UIColor colorWithRed:0.72549 green:0.63137 blue:0.27843 alpha:1.0];
        self.navigationItem.rightBarButtonItem = button;
    } else {
        // set the right button item to be the search button
        self.navigationItem.rightBarButtonItem = self.rightButtonItem;
    }
    _isSearching = isSearching;
}

#pragma mark - Map

- (NSArray *)mapItemsFromPlistInBundle:(NSString *)nameInBundle
{
    NSArray *plistArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:nameInBundle ofType:@"plist"]];
    NSMutableArray *finalArray = [[NSMutableArray alloc] initWithCapacity:plistArray.count];
    for (NSDictionary *d in plistArray)
    {
        [finalArray addObject:[[CMapItem alloc] initWithDictionary:d]];
    }
    
    return [finalArray copy];
}

- (NSArray *)mapItemsFromPFObjects:(NSArray *)objectsArray
{
    NSMutableArray *finalArray = [[NSMutableArray alloc] initWithCapacity:objectsArray.count];
    for (PFObject *p in objectsArray)
    {
        [finalArray addObject:[[CMapItem alloc] initWithTitle:p[@"title"]
                                                     subtitle:p[@"subtitle"]
                                                     itemType:[(NSNumber *)p[@"itemType"] intValue]
                                                     location:CLLocationCoordinate2DMake([(NSNumber *)p[@"latitude"] doubleValue], [(NSNumber *)p[@"longitude"] doubleValue])]];
    }
    
    return [finalArray copy];
}

- (void)dropPinsForMapItems:(NSArray *)items
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    for (CMapItem *annotation in items)
    {
        [self.mapView addAnnotation:annotation];
    }
    
    if (parkingSaved) {
        // drop parking spot pin
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.title = @"Parking Spot";
        annotation.coordinate = self.parkingCoordinates;
        
        self.parkingAnnotation = annotation;
        [self.mapView addAnnotation:annotation];
    }
}

#pragma mark - Map View Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    /* User Location */
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    /* Everything Else */
    
    if ([annotation isKindOfClass:[CMapItem class]]) {
        CMapItem *mapItem = (CMapItem *)annotation;
        switch (mapItem.itemType) {
            case kATMType:
            {
                static NSString *bankIdentifier = @"bank-MapAnnotationIdentifier";
                
                return [self generateMapAnnotationViewWithIdentifier:bankIdentifier annotation:mapItem imageName:@"Bank"];
                
                break;
            }
            case kBathroomType:
            {
                static NSString *toiletIdentifier = @"toilet-MapAnnotationIdentifier";
                
                return [self generateMapAnnotationViewWithIdentifier:toiletIdentifier annotation:mapItem imageName:@"toilet"];
                
                break;
            }
            case kBoothType:
            {
                static NSString *boothIdentifier = @"booth-MapAnnotationIdentifier";
                
                return [self generateMapAnnotationViewWithIdentifier:boothIdentifier annotation:mapItem imageName:@"booth"];
                
                break;
            }
            case kEmergencyType:
            {
                if ([mapItem.title isEqualToString:@"Defibrillator"]) {
                    static NSString *AEDIdentifier = @"AED-MapAnnotationIdentifier";
                    
                    return [self generateMapAnnotationViewWithIdentifier:AEDIdentifier annotation:mapItem imageName:@"AED"];
                } else {
                    static NSString *FirstAidIdentifier = @"FirstAid-MapAnnotationIdentifier";
                    
                    return [self generateMapAnnotationViewWithIdentifier:FirstAidIdentifier annotation:mapItem imageName:@"firstaid"];
                }
                break;
            }
            case kFoodType:
            {
                static NSString *foodIdentifier = @"food-MapAnnotationIdentifier";
                
                return [self generateMapAnnotationViewWithIdentifier:foodIdentifier annotation:mapItem imageName:@"food"];
                
                break;
            }
            case kGameType:
            {
                static NSString *gameIdentifier = @"game-MapAnnotationIdentifier";
                
                return [self generateMapAnnotationViewWithIdentifier:gameIdentifier annotation:mapItem imageName:@"leaderboard"];
                
                break;
            }
            case kKiddielandType:
            {
                static NSString *kiddieIdentifier = @"kiddie-MapAnnotationIdentifier";
                
                return [self generateMapAnnotationViewWithIdentifier:kiddieIdentifier annotation:mapItem imageName:@"ball"];
                
                break;
            }
            case kOtherType:
            {
                if ([mapItem.title isEqualToString:@"Art Gallery"]) {
                    static NSString *artIdentifier = @"art-MapAnnotationIdentifier";
                    
                    return [self generateMapAnnotationViewWithIdentifier:artIdentifier annotation:mapItem imageName:@"art"];
                } else if ([mapItem.title isEqualToString:@"Auction"]) {
                    static NSString *auctionIdentifier = @"auction-MapAnnotationIdentifier";
                    
                    return [self generateMapAnnotationViewWithIdentifier:auctionIdentifier annotation:mapItem imageName:@"bust"];
                } else {
                    static NSString *showIdentifier = @"show-MapAnnotationIdentifier";
                    
                    return [self generateMapAnnotationViewWithIdentifier:showIdentifier annotation:mapItem imageName:@"variety"];
                }
                break;
            }
            case kRideCouponType:
            {
                static NSString *ridecouponIdentifier = @"ridecoupon-MapAnnotationIdentifier";
                
                return [self generateMapAnnotationViewWithIdentifier:ridecouponIdentifier annotation:mapItem imageName:@"ridecoupon"];
                
                break;
            }
            case kRideType:
            {
                static NSString *rideIdentifier = @"ride-MapAnnotationIdentifier";
                
                return [self generateMapAnnotationViewWithIdentifier:rideIdentifier annotation:mapItem imageName:@"ride"];
                
                break;
            }
            case kScripType:
            {
                static NSString *scripIdentifier = @"scrip-MapAnnotationIdentifier";
                
                return [self generateMapAnnotationViewWithIdentifier:scripIdentifier annotation:mapItem imageName:@"scrip"];

                break;
            }
        }
    } else {
        
        MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"mapitems"];
        if (!pin) pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"mapitems"];
        
        if([annotation.title isEqualToString:@"Scrip"]||[annotation.title isEqualToString:@"Ride Tickets"]){
            pin.pinColor = MKPinAnnotationColorGreen;
            
        }
        else if ([annotation.title isEqualToString:@"Parking Spot"]){
            pin.pinColor = MKPinAnnotationColorRed;
        }
        else{
            pin.pinColor = MKPinAnnotationColorPurple;
        }
        
        pin.animatesDrop=NO;
        pin.canShowCallout = YES;
        pin.calloutOffset = CGPointMake(-10, 0);
        
        return pin;
    }
}

- (MKAnnotationView *)generateMapAnnotationViewWithIdentifier:(NSString *)identifier annotation:(CMapItem *)annotation imageName:(NSString *)imageName
{
    MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                       reuseIdentifier:identifier];
        annotationView.image = [UIImage imageNamed:imageName];
        annotationView.canShowCallout = YES;
        annotationView.calloutOffset = CGPointMake(0, 0);
    } else {
        annotationView.annotation = annotation;
    }
    
    return annotationView;
}


#pragma mark - Navigation

- (IBAction)searchButtonTapped:(id)sender
{
    
}

- (void)doneButtonTapped
{
    self.isSearching = NO;
    [self dropPinsForMapItems:self.mapItems];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (parkingSaved)
        {
            // clear the user's parking
            parkingSaved = NO;
            
            [self.mapView removeAnnotation:self.parkingAnnotation];
            self.parkingAnnotation = nil;
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:nil forKey:kLatitudeKey];
            [defaults setObject:nil forKey:kLongitudeKey];
            [defaults synchronize];
            
        } else {
            // ask for permission
            // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
            
            if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
                
                // attempt to save the user's parking
                [self.locationManager startUpdatingLocation];
                
                // start a timer so location updating will time out eventually
                [self performSelector:@selector(cancelLocationUpdates) withObject:nil afterDelay:20];
                
                // update UI
                UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                UIBarButtonItem *indicator = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
                self.navigationItem.leftBarButtonItem = indicator;
                [indicatorView startAnimating];
            } else {
                NSLog(@"LocationServices access denied.");
                if (self.displayLocationError) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                                    message:@"Enable location services in Settings to save your parking spot."
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            }
            
            
        }
    }
}

- (void)cancelLocationUpdates
{
    if (self.bestLocation) {
        NSLog(@"Going with the best location <= 100m found.");
        [self saveCurrentLocation:self.bestLocation.coordinate];
        self.bestLocation = nil;
    }
    else if (self.locationManager) {
        [self stopUpdatingLocation];
        // explain that parking spot saving failed
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not find current location"
                                                    message:@"Your parking spot could not be saved because your current location could not be found."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
        [alert show];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *newLocation = [locations lastObject];
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (fabs(howRecent) < 15.0) {
        if (!self.bestLocation) {
            self.bestLocation = newLocation;
            NSLog(@"Created bestLocation.");
        } else if (self.bestLocation.horizontalAccuracy >= newLocation.horizontalAccuracy) {
            self.bestLocation = newLocation;
            NSLog(@"Found more accurate location!");
        }
        if (self.bestLocation.horizontalAccuracy <= 15.0f) {
            NSLog(@"Found a very accurate location.");
            [self saveCurrentLocation:self.bestLocation.coordinate];
            self.bestLocation = nil;
        }
    }
    
     NSLog(@"%@", newLocation);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if(error.code == kCLErrorDenied) {
        [self stopUpdatingLocation];
    } else if(error.code == kCLErrorLocationUnknown) {
        // retry
    } else {
        NSLog(@"didFailWithError: %@", error);
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Location Error" message:@"Failed to Find Parking Location." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    }
}

- (void)saveCurrentLocation:(CLLocationCoordinate2D)coordinate
{
    [self stopUpdatingLocation];
    if (!parkingSaved) {
        parkingSaved = YES;
    
        self.parkingCoordinates = coordinate;
    
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.title = @"Parking Spot";
        annotation.coordinate = coordinate;
    
        self.parkingAnnotation = annotation;
        [self.mapView addAnnotation:annotation];
        
        [self.mapView setCenterCoordinate:coordinate animated:YES];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithDouble:coordinate.latitude] forKey:kLatitudeKey];
        [defaults setObject:[NSNumber numberWithDouble:coordinate.longitude] forKey:kLongitudeKey];
        [defaults synchronize];
    }
}

- (void)stopUpdatingLocation
{
    [self.locationManager stopUpdatingLocation];
    [CMapViewController cancelPreviousPerformRequestsWithTarget:self]; // cancel the timer
    
    // Update the UI
    self.navigationItem.leftBarButtonItem = [self createParkingButtonItem];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusDenied) {
        self.displayLocationError = YES;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                        message:@"Enable location services in Settings to save your parking spot."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self stopUpdatingLocation];
    }
}

- (IBAction)parkingButtonTapped:(id)sender {
    
    if ([CLLocationManager locationServicesEnabled]) {
        // display an action sheet prompting the user to either save their parking or clear it
        if (parkingSaved)
        {
            // give the user an option to clear their parking spot
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:@"Clear Parking"
                                                            otherButtonTitles:nil];
            [actionSheet showFromTabBar:self.tabBarController.tabBar];
        } else {
            // give the user an option to save their parking spot
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Save Parking",nil];
            [actionSheet showFromTabBar:self.tabBarController.tabBar];
        }
    } else {
        // ask the user to enable location services
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                        message:@"Enable location services in Settings to save your parking spot."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self stopUpdatingLocation];
    }
}

- (UIBarButtonItem *)createParkingButtonItem
{
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cars"] style:UIBarButtonItemStylePlain target:self action:@selector(parkingButtonTapped:)];
    bbi.tintColor = [UIColor colorWithRed:0.72549 green:0.63137 blue:0.27843 alpha:1.0];
    
    return bbi;
}

- (IBAction)unwindToMap:(UIStoryboardSegue *)unwindSegue
{
    // stuff happens here I guess
    // this is used in the storyboard, don't touch this even though there's not code here!
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"searchMap"])
    {
        CMapPickerViewController *pvc = (CMapPickerViewController *)[(UINavigationController *)[segue destinationViewController] topViewController];
        [pvc setMapItems:self.mapItems];
        pvc.mapViewController = self;
    }
}

- (void)setSelectedItems:(NSArray *)items
{
    self.isSearching = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
    [self dropPinsForMapItems:items];
}

- (IBAction)locationButtonTapped:(UIButton *)sender {
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mapView.showsUserLocation = YES;
        [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    } else {
        // ask the user to enable location services
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                        message:@"Enable location services in Settings to view your location."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self.locationManager stopUpdatingLocation];
    }
}

@end
