//
//  CMapItem.m
//  iCarnival
//
//  Created by Nathanael Wallace on 1/19/14.
//  Copyright (c) 2014 Punahou School - Nathan Wallace '14. All rights reserved.
//

#import "CMapItem.h"

@implementation CMapItem

- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle itemType:(CMapItemType)type location:(CLLocationCoordinate2D)location
{
    if (self = [super init])
    {
        self.title = title;
        self.subtitle = subtitle;
        self.coordinate = location;
        
        _itemType = type;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    CLLocationCoordinate2D loc = CLLocationCoordinate2DMake([(NSNumber *)dictionary[@"latitude"] doubleValue], [(NSNumber *)dictionary[@"longitude"] doubleValue]);
    return [self initWithTitle:dictionary[@"title"] subtitle:dictionary[@"subtitle"] itemType:[(NSNumber *)dictionary[@"itemType"] intValue] location:loc];
}

- (id)init
{
    return [self initWithTitle:@"" subtitle:@"" itemType:kOtherType location:CLLocationCoordinate2DMake(0, 0)];
}

- (NSDictionary *)serialize
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setObject:self.title forKey:@"title"];
    [result setObject:self.subtitle forKey:@"subtitle"];
    [result setObject:[NSNumber numberWithInt:self.itemType] forKey:@"itemType"];
    [result setObject:[NSNumber numberWithDouble:self.coordinate.latitude] forKey:@"latitude"];
    [result setObject:[NSNumber numberWithDouble:self.coordinate.longitude] forKey:@"longitude"];
    
    return [result copy];
}

- (NSComparisonResult)compareItems:(CMapItem *)otherItem
{
    if (self.itemType > otherItem.itemType) {
        return NSOrderedDescending;
    } else if (self.itemType < otherItem.itemType) {
        return NSOrderedAscending;
    } else {
        return [self.title localizedCaseInsensitiveCompare:otherItem.title];
    }
}

+ (NSString *)stringFromType:(CMapItemType)type
{
    switch (type) {
        case kOtherType: return @"Other";
        case kEmergencyType: return @"Emergency";
        case kBoothType: return @"Booths";
        case kKiddielandType: return @"Kiddieland";
        case kGameType: return @"Games";
        case kRideType: return @"Rides";
        case kFoodType: return @"Food";
        case kATMType: return @"ATMs";
        case kBathroomType: return @"Restrooms";
        case kRideCouponType: return @"Ride Coupons";
        case kScripType: return @"Scrip";
    }
}

/*+ (void)sortPlist
{
    NSArray *plistArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"items" ofType:@"plist"]];
    NSMutableArray *finalArray = [[NSMutableArray alloc] initWithCapacity:plistArray.count];
    for (NSDictionary *d in plistArray)
    {
        [finalArray addObject:[[CMapItem alloc] initWithDictionary:d]];
    }
    
    [finalArray sortUsingSelector:@selector(compareItems:)];
    
    NSMutableArray *serialized = [[NSMutableArray alloc] init];
    [serialized addObject:@"Cheese"];
    for (CMapItem *i in finalArray) {
        [serialized addObject:[i serialize]];
    }
    
    NSArray *sysPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask, YES);
    NSString *prefsDirectory = [[sysPaths objectAtIndex:0] stringByAppendingPathComponent:@"/Preferences"];
    
    NSString *outputFilePath=[prefsDirectory stringByAppendingPathComponent:@"items.plist"];
    NSLog(@"%@",outputFilePath);
    
    [[serialized copy] writeToFile:outputFilePath atomically:YES];
}*/

/*+ (void)generatePlist
{
    CLLocationCoordinate2D temp;

    temp.latitude=21.302454;
    temp.longitude=-157.83096;
    CMapItem *zipper = [[CMapItem alloc] init];
    [zipper setTitle:@"Zipper"];
    zipper.location = temp;
    zipper.itemType = kRideType;
    
    temp.latitude=21.303004;
    temp.longitude=-157.832122;
    CMapItem *dizzyDagrons = [[CMapItem alloc] init];
    [dizzyDagrons setTitle:@"Dizzy Dragons"];
    dizzyDagrons.location = temp;
    dizzyDagrons.itemType = kRideType;
    
    temp.latitude=21.303199;
    temp.longitude=-157.831929;
    CMapItem *miniCoaster = [[CMapItem alloc] init];
    [miniCoaster setTitle:@"Mini-Coaster"];
    miniCoaster.location = temp;
    miniCoaster.itemType = kRideType;
    
    temp.latitude=21.303324;
    temp.longitude=-157.831816;
    CMapItem * Helicopter = [[CMapItem alloc] init];
    [Helicopter setTitle:@"Helicopter"];
    Helicopter.location = temp;
    Helicopter.itemType = kRideType;
    
    temp.latitude=21.303239;
    temp.longitude=-157.831698;
    CMapItem * Speedway = [[CMapItem alloc] init];
    [Speedway setTitle:@"Speedway"];
    Speedway.location = temp;
    Speedway.itemType = kRideType;
    
    temp.latitude=21.303374;
    temp.longitude=-157.831526;
    CMapItem * face = [[CMapItem alloc] init];
    [face setTitle:@"Body Painting"];
    face.location = temp;
    face.itemType = kBoothType;
    
    temp.latitude=21.303094;
    temp.longitude=-157.831779;
    CMapItem * MGR = [[CMapItem alloc] init];
    [MGR setTitle:@"Merry-Go-Round"];
    MGR.location = temp;
    MGR.itemType = kRideType;
    
    ///start adding from here down
    temp.latitude=21.302702;
    temp.longitude=-157.831545;
    CMapItem * Inverter = [[CMapItem alloc] init];
    [Inverter setTitle:@"Crazy Plane"];
    Inverter.location = temp;
    Inverter.itemType = kRideType;
    
    temp.latitude=21.303029;
    temp.longitude=-157.831443;
    CMapItem * pharao = [[CMapItem alloc] init];
    [pharao setTitle:@"Pharaoh's Fury"];
    pharao.location = temp;
    pharao.itemType = kRideType;
    
    temp.latitude=21.303044;
    temp.longitude=-157.831229;
    CMapItem * ferris = [[CMapItem alloc] init];
    [ferris setTitle:@"Century Wheel"];
    ferris.location = temp;
    ferris.itemType = kRideType;
    
    temp.latitude=21.302567;
    temp.longitude=-157.831143;
    CMapItem * dagronCoaster = [[CMapItem alloc] init];
    [dagronCoaster setTitle:@"Music Express"];
    dagronCoaster.location = temp;
    dagronCoaster.itemType = kRideType;
    
    temp.latitude=21.302492;
    temp.longitude=-157.83103;
    CMapItem * wave = [[CMapItem alloc] init];
    [wave setTitle:@"Wave Swinger"];
    wave.location = temp;
    wave.itemType = kRideType;
    
    temp.latitude=21.302627;
    temp.longitude=-157.831231;
    CMapItem * fire = [[CMapItem alloc] init];
    [fire setTitle:@"Fire Ball"];
    fire.location = temp;
    fire.itemType = kRideType;
    
    temp.latitude=21.303017;
    temp.longitude=-157.831014;
    CMapItem * spring = [[CMapItem alloc] init];
    [spring setTitle:@"Spring CMapItem"];
    spring.location = temp;
    spring.itemType = kRideType;
    
    temp.latitude=21.302949;
    temp.longitude=-157.830821;
    CMapItem * bumperCars = [[CMapItem alloc] init];
    [bumperCars setTitle:@"Traffic Jam"];
    bumperCars.location = temp;
    bumperCars.itemType = kRideType;
    
    temp.latitude=21.302864;
    temp.longitude=-157.830716;
    CMapItem * Scooters = [[CMapItem alloc] init];
    [Scooters setTitle:@"Scooter"];
    Scooters.location = temp;
    Scooters.itemType = kRideType;
    
    temp.latitude=21.302774;
    temp.longitude=-157.830598;
    CMapItem * Sizzler = [[CMapItem alloc] init];
    [Sizzler setTitle:@"Super Sizzler"];
    Sizzler.location = temp;
    Sizzler.itemType = kRideType;
    
    temp.latitude=21.302684;
    temp.longitude=-157.830494;
    CMapItem * Cliffhanger = [[CMapItem alloc] init];
    [Cliffhanger setTitle:@"Cliff Hanger"];
    Cliffhanger.location = temp;
    Cliffhanger.itemType = kRideType;
    
    
    
    
    temp.latitude=21.303049;
    temp.longitude=-157.831602;
    CMapItem * burgers=[[CMapItem alloc]init];
    [burgers setTitle:@"Hamburger/Hot Dog"];
    burgers.location =temp;
    burgers.itemType = kFoodType;
    burgers.subtitle = @"Ewa";
    
    temp.latitude=21.302939;
    temp.longitude=-157.83172;
    CMapItem * Noodles=[[CMapItem alloc]init];
    [Noodles setTitle:@"Noodles"];
    Noodles.location =temp;
    Noodles.itemType = kFoodType;
    //Noodles.subtitle = @"ewa";
    
    temp.latitude=21.303114;
    temp.longitude=-157.83151;
    CMapItem * Saimin=[[CMapItem alloc]init];
    [Saimin setTitle:@"Saimin"];
    Saimin.location =temp;
    Saimin.itemType = kFoodType;
    //Noodles.subtitle = @"ewa";
    
    temp.latitude=21.303504;
    temp.longitude=-157.831237;
    CMapItem * malasada1=[[CMapItem alloc]init];
    [malasada1 setTitle:@"Malasadas"];
    malasada1.location =temp;
    malasada1.itemType = kFoodType;
    malasada1.subtitle = @"Ewa";
    
    
    temp.latitude=21.303099;
    temp.longitude=-157.831247;
    CMapItem * bean=[[CMapItem alloc]init];
    [bean setTitle:@"Portugese Bean Soup"];
    bean.location =temp;
    bean.itemType = kFoodType;
    //Noodles.subtitle = @"ewa";
    
    temp.latitude=21.303104;
    temp.longitude=-157.831146;
    CMapItem * IceCream=[[CMapItem alloc]init];
    [IceCream setTitle:@"Ice Cream"];
    IceCream.location =temp;
    IceCream.itemType = kFoodType;
    //Noodles.subtitle = @"ewa";
    
    temp.latitude=21.303064;
    temp.longitude=-157.830947;
    CMapItem * Smoothies=[[CMapItem alloc]init];
    [Smoothies setTitle:@"Smoothie"];
    Smoothies.location =temp;
    Smoothies.itemType = kFoodType;
    //Noodles.subtitle = @"ewa";
    
    temp.latitude=21.303079;
    temp.longitude=-157.831028;
    CMapItem * taco=[[CMapItem alloc]init];
    [taco setTitle:@"Taco Salad & Nachos"];
    taco.location =temp;
    taco.itemType = kFoodType;
    //Noodles.subtitle = @"ewa";
    
    temp.latitude=21.302649;
    temp.longitude=-157.830201;
    CMapItem * Corn=[[CMapItem alloc]init];
    [Corn setTitle:@"Corn"];
    Corn.location =temp;
    Corn.itemType = kFoodType;
    //Noodles.subtitle = @"ewa";
    
    temp.latitude=21.302579;
    temp.longitude=-157.830105;
    CMapItem * chicken=[[CMapItem alloc]init];
    [chicken setTitle:@"Chicken Plate Lunch"];
    chicken.location =temp;
    chicken.itemType = kFoodType;
    //Noodles.subtitle = @"ewa";
    
    temp.latitude=21.302519;
    temp.longitude=-157.830014;
    CMapItem * Gyros=[[CMapItem alloc]init];
    [Gyros setTitle:@"Gyros"];
    Gyros.location =temp;
    Gyros.itemType = kFoodType;
    //Noodles.subtitle = @"ewa";
    
    temp.latitude=21.302364;
    temp.longitude=-157.829869;
    CMapItem * burgers2=[[CMapItem alloc]init];
    [burgers2 setTitle:@"Hamburger/Hot Dog"];
    burgers2.location =temp;
    burgers2.itemType = kFoodType;
    burgers2.subtitle = @"Waikiki";
    
    temp.latitude=21.302304;
    temp.longitude=-157.829772;
    CMapItem * beverages2=[[CMapItem alloc]init];
    [beverages2 setTitle:@"Beverage Centers"];
    beverages2.location =temp;
    beverages2.itemType = kFoodType;
    beverages2.subtitle = @"Waikiki";
    
    temp.latitude=21.30185;
    temp.longitude=-157.830094;
    CMapItem * malasadas2=[[CMapItem alloc]init];
    [malasadas2 setTitle:@"Malasadas"];
    malasadas2.location =temp;
    malasadas2.itemType = kFoodType;
    malasadas2.subtitle = @"Waikiki";
    
    
    
    
    temp.latitude=21.302764;
    temp.longitude=-157.831703;
    CMapItem * scrip=[[CMapItem alloc] init];
    [scrip setTitle:@"Scrip"];
    scrip.location =temp;
    scrip.itemType = kScripType;
    
    temp.latitude=21.302924;
    temp.longitude=-157.831623;
    CMapItem * scrip2=[[CMapItem alloc] init];
    [scrip2 setTitle:@"Scrip"];
    scrip2.location =temp;
    scrip2.itemType = kScripType;
    
    temp.latitude=21.302637;
    temp.longitude=-157.831365;
    CMapItem * scrip3=[[CMapItem alloc] init];
    [scrip3 setTitle:@"Scrip"];
    scrip3.location =temp;
    scrip3.itemType = kScripType;
    
    temp.latitude=21.302364;
    temp.longitude=-157.830926;
    CMapItem * scrip4=[[CMapItem alloc] init];
    [scrip4 setTitle:@"Scrip"];
    scrip4.location =temp;
    scrip4.itemType = kScripType;
    
    temp.latitude=21.302759;
    temp.longitude=-157.831392;
    CMapItem * scrip5=[[CMapItem alloc] init];
    [scrip5 setTitle:@"Scrip"];
    scrip5.location =temp;
    scrip5.itemType = kScripType;
    
    temp.latitude=21.302659;
    temp.longitude=-157.83095;
    CMapItem * scrip6=[[CMapItem alloc] init];
    [scrip6 setTitle:@"Scrip"];
    scrip6.location =temp;
    scrip6.itemType = kScripType;
    
    temp.latitude=21.302295;
    temp.longitude=-157.830019;
    CMapItem * scrip7=[[CMapItem alloc] init];
    [scrip7 setTitle:@"Scrip"];
    scrip7.location =temp;
    scrip7.itemType = kScripType;
    
    temp.latitude=21.302787;
    temp.longitude=-157.830322;
    CMapItem * scrip8=[[CMapItem alloc] init];
    [scrip8 setTitle:@"Scrip"];
    scrip8.location =temp;
    scrip8.itemType = kScripType;
    
    temp.latitude=21.302829;
    temp.longitude=-157.831623;
    CMapItem * tickets=[[CMapItem alloc] init];
    [tickets setTitle:@"Ride Coupons"];
    tickets.location =temp;
    tickets.itemType = kRideCouponType;
    
    temp.latitude=21.302879;
    temp.longitude=-157.831408;
    CMapItem * tickets2=[[CMapItem alloc] init];
    [tickets2 setTitle:@"Ride Coupons"];
    tickets2.location =temp;
    tickets2.itemType = kRideCouponType;
    
    temp.latitude=21.302719;
    temp.longitude=-157.831078;
    CMapItem * tickets3=[[CMapItem alloc] init];
    [tickets3 setTitle:@"Ride Coupons"];
    tickets3.location =temp;
    tickets3.itemType = kRideCouponType;
    
    temp.latitude=21.302567;
    temp.longitude=-157.830829;
    CMapItem * tickets4=[[CMapItem alloc] init];
    [tickets4 setTitle:@"Ride Coupons"];
    tickets4.location =temp;
    tickets4.itemType = kRideCouponType;
    
    
    temp.latitude=21.303279;
    temp.longitude=-157.830968;
    CMapItem * sound=[[CMapItem alloc] init];
    [sound setTitle:@"Sound Booth"];
    sound.location =temp;
    sound.itemType = kBoothType;
    
    
    
    temp.latitude=21.303059;
    temp.longitude=-157.830877;
    CMapItem * Bowling=[[CMapItem alloc] init];
    [Bowling setTitle:@"Bowling"];
    Bowling.location =temp;
    Bowling.itemType = kGameType;
    
    temp.latitude=21.303001;
    temp.longitude=-157.830761;
    CMapItem * Ring=[[CMapItem alloc] init];
    [Ring setTitle:@"Ring Toss"];
    Ring.location =temp;
    Ring.itemType = kGameType;
    
    temp.latitude=21.30294;
    temp.longitude=-157.83068;
    CMapItem * puka=[[CMapItem alloc] init];
    [puka setTitle:@"Puka Horseshoes"];
    puka.location =temp;
    puka.itemType = kGameType;
    
    temp.latitude=21.302889;
    temp.longitude=-157.830636;
    CMapItem * Whirlpool=[[CMapItem alloc] init];
    [Whirlpool setTitle:@"Whirlpool"];
    Whirlpool.location =temp;
    Whirlpool.itemType = kGameType;
    
    temp.latitude=21.302834;
    temp.longitude=-157.830561;
    CMapItem * frogs=[[CMapItem alloc] init];
    [frogs setTitle:@"Frogs in the Lily Pond"];
    frogs.location =temp;
    frogs.itemType = kGameType;
    
    temp.latitude=21.302779;
    temp.longitude=-157.830486;
    CMapItem * Strongman=[[CMapItem alloc] init];
    [Strongman setTitle:@"Strong Man"];
    Strongman.location =temp;
    Strongman.itemType = kGameType;
    
    temp.latitude=21.302724;
    temp.longitude=-157.830411;
    CMapItem * Basketball=[[CMapItem alloc] init];
    [Basketball setTitle:@"Basketball"];
    Basketball.location =temp;
    Basketball.itemType = kGameType;
    
    temp.latitude=21.302336;
    temp.longitude=-157.829065;
    CMapItem * golf=[[CMapItem alloc] init];
    [golf setTitle:@"Miniature Golf"];
    golf.location =temp;
    golf.itemType = kGameType;
    
    temp.latitude=21.302319;
    temp.longitude=-157.829146;
    CMapItem * Ducks=[[CMapItem alloc] init];
    [Ducks setTitle:@"Ducks"];
    Ducks.location =temp;
    Ducks.itemType = kGameType;
    
    temp.latitude=21.302272;
    temp.longitude=-157.829072;
    CMapItem * Menehune=[[CMapItem alloc] init];
    [Menehune setTitle:@"Menehune Strong Man"];
    Menehune.location =temp;
    Menehune.itemType = kGameType;
    
    temp.latitude=21.302276;
    temp.longitude=-157.829206;
    CMapItem * fish=[[CMapItem alloc] init];
    [fish setTitle:@"Fish Swish"];
    fish.location =temp;
    fish.itemType = kGameType;
    
    temp.latitude=21.302118;
    temp.longitude=-157.829326;
    CMapItem * beanBag=[[CMapItem alloc] init];
    [beanBag setTitle:@"Bean Bag"];
    beanBag.location =temp;
    beanBag.itemType = kKiddielandType;
    
    temp.latitude=21.302168;
    temp.longitude=-157.829391;
    CMapItem * grabBag=[[CMapItem alloc] init];
    [grabBag setTitle:@"Grab Bag"];
    grabBag.location =temp;
    grabBag.itemType = kKiddielandType;
    
    temp.latitude=21.302203;
    temp.longitude=-157.829326;
    CMapItem * sand=[[CMapItem alloc] init];
    [sand setTitle:@"Sand Pile"];
    sand.location =temp;
    sand.itemType = kKiddielandType;
    
    temp.latitude=21.302162;
    temp.longitude=-157.829271;
    CMapItem * ticTac=[[CMapItem alloc] init];
    [ticTac setTitle:@"Tic-Tac-Toe"];
    ticTac.location =temp;
    ticTac.itemType = kKiddielandType;
    
    temp.latitude=21.30212;
    temp.longitude=-157.82951;
    CMapItem * splat=[[CMapItem alloc] init];
    [splat setTitle:@"Splat Trap"];
    splat.location =temp;
    splat.itemType = kBoothType;
    
    
    temp.latitude=21.30362;
    temp.longitude=-157.82859;
    CMapItem * plate=[[CMapItem alloc] init];
    [plate setTitle:@"Hawaiian Plate"];
    plate.location =temp;
    plate.itemType = kFoodType;
    
    temp.latitude=21.3021;
    temp.longitude=-157.829909;
    CMapItem * jam=[[CMapItem alloc] init];
    [jam setTitle:@"Jams and Jellies"];
    jam.location =temp;
    jam.itemType = kBoothType;
    
    temp.latitude=21.301892;
    temp.longitude=-157.829896;
    CMapItem * trees=[[CMapItem alloc] init];
    [trees setTitle:@"Plants"];
    trees.location =temp;
    trees.itemType = kBoothType;
    
    temp.latitude=21.303289;
    temp.longitude=-157.831087;
    CMapItem * Haku=[[CMapItem alloc] init];
    [Haku setTitle:@"Haku Lei"];
    Haku.location =temp;
    Haku.itemType = kBoothType;
    
    temp.latitude=21.30213;
    temp.longitude=-157.830193;
    CMapItem * elephant=[[CMapItem alloc] init];
    [elephant setTitle:@"White Elephant"];
    elephant.location =temp;
    elephant.itemType = kBoothType;
    
    temp.latitude=21.30194;
    temp.longitude=-157.830226;
    CMapItem * WillCall=[[CMapItem alloc] init];
    [WillCall setTitle:@"Will Call"];
    WillCall.location =temp;
    WillCall.itemType = kBoothType;
    /////
    temp.latitude=21.303421;
    temp.longitude=-157.83062;
    CMapItem * Art=[[CMapItem alloc] init];
    [Art setTitle:@"Art Gallery"];
    Art.location =temp;
    Art.itemType = kOtherType;
    
    temp.latitude=21.303231;
    temp.longitude=-157.830925;
    CMapItem * beverages1=[[CMapItem alloc]init];
    [beverages1 setTitle:@"Beverages"];
    beverages1.location =temp;
    beverages1.itemType = kFoodType;
    beverages1.subtitle = @"Ewa";
    
    temp.latitude=21.303134;
    temp.longitude=-157.830802;
    CMapItem * TShirt=[[CMapItem alloc] init];
    [TShirt setTitle:@"T-Shirt Sales"];
    TShirt.location =temp;
    TShirt.itemType = kBoothType;
    
    temp.latitude=21.303026;
    temp.longitude=-157.830465;
    CMapItem * Auction=[[CMapItem alloc] init];
    [Auction setTitle:@"Auction"];
    Auction.location =temp;
    Auction.itemType = kOtherType;
    
    
    temp.latitude=21.302782;
    temp.longitude=-157.82993;
    CMapItem * Variety=[[CMapItem alloc] init];
    [Variety setTitle:@"Variety Show"];
    Variety.location =temp;
    Variety.itemType = kOtherType;
    
    temp.latitude=21.30198;
    temp.longitude=-157.829391;
    CMapItem * Prize=[[CMapItem alloc] init];
    [Prize setTitle:@"Prize Exchange"];
    Prize.location =temp;
    Prize.itemType = kKiddielandType;
    
    temp.latitude=21.302237;
    temp.longitude=-157.829142;
    CMapItem * Airball=[[CMapItem alloc] init];
    [Airball setTitle:@"Airball"];
    Airball.location =temp;
    Airball.itemType = kGameType;
    
    temp.latitude=21.302235;
    temp.longitude=-157.829265;
    CMapItem * Wheelf=[[CMapItem alloc] init];
    [Wheelf setTitle:@"Wheel of Fortune"];
    Wheelf.location =temp;
    Wheelf.itemType = kGameType;
    
    temp.latitude=21.302201;
    temp.longitude=-157.829205;
    CMapItem * kbb=[[CMapItem alloc] init];
    [kbb setTitle:@"Kiddie Basketball"];
    kbb.location =temp;
    kbb.itemType = kKiddielandType;
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    
    [items addObject:zipper];
    [items addObject:miniCoaster];
    [items addObject:dizzyDagrons];
    [items addObject:Helicopter];
    [items addObject:MGR];
    [items addObject:Inverter];
    [items addObject:pharao];
    [items addObject:ferris];
    [items addObject:dagronCoaster];
    [items addObject:wave];
    [items addObject:fire];
    [items addObject:spring];
    [items addObject:bumperCars];
    [items addObject:Scooters];
    [items addObject:Sizzler];
    [items addObject:Cliffhanger];
    [items addObject:Speedway];
    
    [items addObject:burgers];
    [items addObject:Saimin];
    [items addObject:Noodles];
    [items addObject:malasada1];
    [items addObject:beverages1];
    [items addObject:bean];
    [items addObject:IceCream];
    [items addObject:Smoothies];
    [items addObject:taco];
    [items addObject:Corn];
    [items addObject:chicken];
    [items addObject:Gyros];
    [items addObject:burgers2];
    [items addObject:beverages2];
    [items addObject:malasadas2];
    [items addObject:plate];
    
    [items addObject:scrip];
    [items addObject:face];
    [items addObject:scrip2];
    [items addObject:scrip3];
    [items addObject:scrip4];
    [items addObject:scrip5];
    [items addObject:scrip6];
    [items addObject:scrip7];
    [items addObject:scrip8];
    [items addObject:tickets];
    [items addObject:tickets2];
    [items addObject:tickets3];
    [items addObject:tickets4];
    [items addObject:sound];
    [items addObject:elephant];
    [items addObject:WillCall];
    [items addObject:jam];
    [items addObject:trees];
    [items addObject:Haku];
    [items addObject:Variety];
    [items addObject:TShirt];
    [items addObject:Auction];
    [items addObject:Art];
    [items addObject:Prize];
    
    [items addObject:Bowling];
    [items addObject:Ring];
    [items addObject:puka];
    [items addObject:Whirlpool];
    [items addObject:frogs];
    [items addObject:Strongman];
    [items addObject:Basketball];
    [items addObject:golf];
    [items addObject:Ducks];
    [items addObject:Menehune];
    [items addObject:fish];
    [items addObject:grabBag];
    [items addObject:beanBag];
    [items addObject:sand];
    [items addObject:ticTac];
    [items addObject:splat];
    [items addObject:Airball];
    [items addObject:Wheelf];
    [items addObject:kbb];
    [items sortUsingSelector:@selector(compareItems:)];
    
    NSMutableArray *serialized = [[NSMutableArray alloc] init];
    [serialized addObject:@"Cheese"];
    for (CMapItem *i in items) {
        [serialized addObject:[i serialize]];
    }
    
    NSArray *sysPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask, YES);
    NSString *prefsDirectory = [[sysPaths objectAtIndex:0] stringByAppendingPathComponent:@"/Preferences"];
    
    NSString *outputFilePath=[prefsDirectory stringByAppendingPathComponent:@"items.plist"];
    NSLog(@"%@",outputFilePath);
    
    [[serialized copy] writeToFile:outputFilePath atomically:YES];
}*/

@end
