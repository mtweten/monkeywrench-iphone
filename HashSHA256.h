//
//  HashSHA256.h
//  monkeywrench
//
//  Created by Nicolas Kline on 6/2/12.
//  Copyright (c) 2012 Apptruism. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface HashSHA256 : NSObject

- (NSString *) hashedValue :(NSString *) key andData: (NSString *) data ;

@end
