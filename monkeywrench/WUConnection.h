//
//  WUConnection.h
//  Ride Weather 2
//
//  Created by Nicolas Kline on 11/3/11.
//  Copyright (c) 2011 Apptruism. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@protocol WUConnectionDelegate
- (void)jsonFinishedLoading:(id)response;
@end

@interface WUConnection : NSObject <RKRequestDelegate>
{
    NSMutableData* receivedData;
    NSURLConnection* conn;
    id <WUConnectionDelegate> delegate;
}

- (NSURL*)buildURL;
- (void)getWeatherJSON:(id)newDelegate;

// JSON Parsing
- (id) objectWithUrl:(NSURL *)url;
- (NSString *)stringWithUrl:(NSURL *)url;
-(NSString*)addQueryStringToUrlString:(NSString *)urlString withDictionary:(NSDictionary *)dictionary;
-(NSData*) hmacForKeyAndData:(NSString *)key data:(NSString *)data;

- (void)sendRequests;
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response;

@property (nonatomic, retain) id  <WUConnectionDelegate> delegate; 

@end
