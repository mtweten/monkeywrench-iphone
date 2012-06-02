//
//  PTPusherMockConnection.h
//  libPusher
//
//  Created by Luke Redpath on 11/05/2012.
//  Copyright (c) 2012 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTPusherConnection.h"

#define kPTPusherSimulatedDisconnectionErrorCode 1001

@interface PTPusherMockConnection : PTPusherConnection

- (void)simulateServerEventNamed:(NSString *)name data:(id)data channel:(NSString *)channelName;
- (void)simulateServerEventNamed:(NSString *)name data:(id)data;
- (void)simulateUnexpectedDisconnection;

@end
