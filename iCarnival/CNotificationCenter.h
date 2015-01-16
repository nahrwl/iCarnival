//
//  CNotificationCenter.h
//  iCarnival
//
//  Created by Nathanael Wallace on 1/22/14.
//  Copyright (c) 2014 Punahou School - Nathan Wallace '14. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CNotificationCenter : NSObject

// Always access an instance of CNotificationCenter through this message
// Behavior of [[CNotificationCenter alloc] init] is undefined
+ (id)sharedNotificationCenter;

- (NSArray *)notificationsForChannel:(NSString *)channel;
- (NSDictionary *)notificationAtIndex:(NSUInteger)index forChannel:(NSString *)channel;

- (BOOL)addNotification:(NSDictionary *)notification toChannel:(NSString *)channel;

@end
