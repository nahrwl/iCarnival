//
//  CNotificationCenter.m
//  iCarnival
//
//  Created by Nathanael Wallace on 1/22/14.
//  Copyright (c) 2014 Punahou School - Nathan Wallace '14. All rights reserved.
//

#import "CNotificationCenter.h"

@interface CNotificationCenter ()

@property (strong, nonatomic) NSMutableDictionary *channels;

- (NSMutableArray *)_notificationsForChannel:(NSString *)channel;

@end

@implementation CNotificationCenter

+ (id)sharedNotificationCenter {
    static CNotificationCenter *sharedMyNotificationCenter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyNotificationCenter = [[self alloc] init];
    });
    return sharedMyNotificationCenter;
}

- (id)init {
    if (self = [super init]) {
        // set default values here
        _channels = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSArray *)notificationsForChannel:(NSString *)channel
{
    return [[self _notificationsForChannel:channel] copy];
}

// private implementation
- (NSMutableArray *)_notificationsForChannel:(NSString *)channel
{
    if (!self.channels[channel]) {
        NSMutableArray *newArray = [[NSMutableArray alloc] init];
        self.channels[channel] = newArray;
    }
    return self.channels[channel];
}

- (NSDictionary *)notificationAtIndex:(NSUInteger)index forChannel:(NSString *)channel
{
    NSMutableArray *array = [self _notificationsForChannel:channel];
    if (index < array.count) {
        return [array objectAtIndex:index];
    }
    return nil;
}

- (BOOL)addNotification:(NSDictionary *)notification toChannel:(NSString *)channel
{
    NSMutableArray *array = [self _notificationsForChannel:channel];
    if (notification && array) {
        [array insertObject:notification atIndex:0];
        return YES;
    }
    return NO;
}

@end
