//
//  CMapItem.h
//  iCarnival
//
//  Created by Nathanael Wallace on 1/19/14.
//  Copyright (c) 2014 Punahou School - Nathan Wallace '14. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef NS_ENUM(NSUInteger, CMapItemType) {
    kFoodType,
    kRideType,
    kGameType,
    kKiddielandType,
    kBoothType,
    kScripType,
    kRideCouponType,
    kBathroomType,
    kOtherType,
    kEmergencyType,
    kATMType
};

@interface CMapItem : MKPointAnnotation

@property (nonatomic) CMapItemType itemType;

- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle itemType:(CMapItemType)type location:(CLLocationCoordinate2D)location;
- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)serialize;
- (NSComparisonResult)compareItems:(CMapItem *)otherItem;

//+ (void)generatePlist;
//+ (void)sortPlist;
+ (NSString *)stringFromType:(CMapItemType)type;

@end
