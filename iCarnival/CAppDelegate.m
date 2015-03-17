//
//  CAppDelegate.m
//  iCarnival
//
//  Created by Nathanael Wallace on 1/18/14.
//  Copyright (c) 2014 Punahou School - Nathan Wallace '14. All rights reserved.
//

#import "CAppDelegate.h"

// ** FABRIC ** //
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import <Crashlytics/Crashlytics.h>


// My headers //
#import "CNotificationsViewController.h"

// KEYS //

static NSString *kFirstLaunchKey = @"iCarnival_kFirstLaunchKey";
static NSString * const kLastUpdatedKey = @"iCarnival-kLastUpdatedKey"; // ALSO CHANGE IN SOCIAL TABLE VIEW CONTROLLER

// MACROS //
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@implementation CAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    /* PARSE */
    
    NSDictionary *parseKeys = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Parse"];
    
    [Parse setApplicationId:parseKeys[@"appID"]
                  clientKey:parseKeys[@"clientKey"]];
    
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        // Register for Push Notifications in OSes less than 8.0
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
         UIRemoteNotificationTypeAlert|
         UIRemoteNotificationTypeSound];
    } else {
        // Register for Push Notifications
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL firstLaunch = [defaults boolForKey:kFirstLaunchKey];
    if (!firstLaunch) {  // opposite because it will be no by default
        // Register the user for the correct channel as necessary
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        
        [currentInstallation addUniqueObject:@"global" forKey:@"channels"];
        [currentInstallation saveInBackground];
        
        [defaults setBool:YES forKey:kFirstLaunchKey];
        [defaults setObject:[NSDate date] forKey:kLastUpdatedKey];
    }
    
    /* TWITTER FABRIC */
    
    [Fabric with:@[TwitterKit, CrashlyticsKit]];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Push

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    
    UITabBarController *tbc = (UITabBarController *)self.window.rootViewController;
    CNotificationsViewController *cnvc = (CNotificationsViewController *)[(UINavigationController *)tbc.viewControllers[0] viewControllers][0];
    
    if ( application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground  )
    {
        //opened from a push notification when the app was on background
        if (tbc) {
            tbc.selectedIndex = 0;
        }
    }
    if (cnvc) {
        if (tbc.selectedIndex == 0) {
            [cnvc updateNotifications];
        } else {
            [cnvc shouldUpdateNotifications];
        }
    }
    
    /*UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Notification"
                                                        message:userInfo[@"alert"]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];*/
    // Extract the alert content
    /*if (userInfo) {
        NSString *content = [userInfo objectForKey:@"alert"];
        if (content) {
            NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
            [d setObject:content forKey:@"alert"];
            [d setObject:[NSDate date] forKey:@"date"];
        
            // add in the notification to the master list
            [[CNotificationCenter sharedNotificationCenter] addNotification:d toChannel:@"soundbooth"];
        }
    }*/
}

@end
