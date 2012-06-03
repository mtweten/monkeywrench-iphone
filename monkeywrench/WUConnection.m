//
//  WUConnection.m
//  Ride Weather
//
//  Created by Nicolas Kline on 10/7/11.
//  Copyright (c) 2011 Apptruism. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
#import "WUConnection.h"
#import "NSStringMD5.h"

@implementation WUConnection
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization Logic
    }
    
    return self;
}

- (void)sendRequests {
    // Perform a simple HTTP GET and call me back with the results
    [ [RKClient sharedClient] get:@"/api/0.10.0/Classes/RKParams.html" delegate:self];
    
    // Send a POST to a remote resource. The dictionary will be transparently
    // converted into a URL encoded representation and sent along as the request body
    // NSDictionary* params = [NSDictionary dictionaryWithObject:@"RestKit" forKey:@"Sender"];
    // [ [RKClient sharedClient] post:@"/other.json" params:params delegate:self];
    
    // DELETE a remote resource from the server
    // [ [RKClient sharedClient] delete:@"/missing_resource.txt" delegate:self];
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
    if ([request isGET]) {
        // Handling GET /foo.xml
        
        if ([response isOK]) {
            // Success! Let's take a look at the data
            NSLog(@"Retrieved XML: %@", [response bodyAsString]);
        }
        
    } else if ([request isPOST]) {
        
        // Handling POST /other.json        
        if ([response isJSON]) {
            NSLog(@"Got a JSON response back from our POST!");
        }
        
    } else if ([request isDELETE]) {
        
        // Handling DELETE /missing_resource.txt
        if ([response isNotFound]) {
            NSLog(@"The resource path '%@' was not found.", [request resourcePath]);
        }
    }
}

- (void)getWeatherJSON:(id)newDelegate
{
    self.delegate = newDelegate;
    NSURL* url = [self buildURL];
    id response = [self stringWithUrl:url];
    [[self delegate] jsonFinishedLoading:response];
}

- (NSURL*)buildURL
{
    NSString* connectionURL1 = @"http://api.pusherapp.com";
    
    NSString* address =	[connectionURL1 stringByAppendingString:@""];
    address = [address stringByAppendingString:@"/apps/21641/channels/test_channel/events"];
//    address = [address stringByAppendingString:[criteria sLongitude]];
//    address = [address stringByAppendingString:connectionURL2];
    
    NSLog(@"URL:");
    NSLog(@"%@", address);
    
    NSString* body = @"{\"message\":\"hello, world\"}";
    
    NSDate * past = [NSDate date];
    NSTimeInterval oldTime = [past timeIntervalSince1970];
    NSString* epocTime = [NSString stringWithFormat:@"%i", oldTime];
    NSString* bodyHash = [body MD5String];
    
    NSString* authSignature = [NSString stringWithFormat:@"POST\n/apps/21641/channels/test_channel/events\nauth_key=0fa225ce2a56dfbbcd17&auth_timestamp=%@&auth_version=1.0&body_md5=%@&name=my_event", epocTime, bodyHash];
    
    NSData* signatureHash = [self hmacForKeyAndData:@"d66cf4a90b44225f4fcf" data:authSignature];
    
    NSArray *keys = [NSArray arrayWithObjects:@"name", @"body_md5", @"auth_key", @"auth_timestamp", @"auth_signature", @"auth_version", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"my_event", bodyHash, @"21641", epocTime, signatureHash, @"1.0", nil];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects 
                                                           forKeys:keys];
    
    address = [self addQueryStringToUrlString:address withDictionary:dictionary];

    return [NSURL URLWithString:address];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // There is enough data to get a response. Reset the response data.
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // TODO: Inform the user of connection error.
    
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Finished recieving data. Call the caller's function.
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    
    [[self delegate] jsonFinishedLoading:receivedData];
    
    receivedData = nil;
    connection = nil;
}


- (NSString *)stringWithUrl:(NSURL *)url
{
        
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url
                                                              cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                          timeoutInterval:30];
    [urlRequest setHTTPMethod:@"POST"];
    
    NSString* body = @"{\"message\":\"hello, world\"}";
    
    [urlRequest addValue:@"monkeywrench" forHTTPHeaderField:@"User-Agent"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPBody:body];
    
	// Fetch the JSON response
	NSData *urlData;
	NSURLResponse *response;
	NSError *error;
	
	// Make synchronous request
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest
									returningResponse:&response
												error:&error];
    
 	// Construct a String around the Data from the response
	return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
}

-(NSString*)urlEscapeString:(NSString *)unencodedString 
{
    CFStringRef originalStringRef = (__bridge_retained CFStringRef)unencodedString;
    NSString *s = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,originalStringRef, NULL, NULL,kCFStringEncodingUTF8);
    CFRelease(originalStringRef);
    return s;
}


-(NSString*)addQueryStringToUrlString:(NSString *)urlString withDictionary:(NSDictionary *)dictionary
{
    NSMutableString *urlWithQuerystring = [[NSMutableString alloc] initWithString:urlString];
    
    for (id key in dictionary) {
        NSString *keyString = [key description];
        NSString *valueString = [[dictionary objectForKey:key] description];
        
        if ([urlWithQuerystring rangeOfString:@"?"].location == NSNotFound) {
            [urlWithQuerystring appendFormat:@"?%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
        } else {
            [urlWithQuerystring appendFormat:@"&%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
        }
    }
    return urlWithQuerystring;
}

-(NSData*) hmacForKeyAndData:(NSString *)key data:(NSString *)data
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
}

@end
