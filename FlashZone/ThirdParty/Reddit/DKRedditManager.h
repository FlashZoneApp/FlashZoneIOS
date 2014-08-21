//
//  DKRedditManager.h
//  FlashZone
//
//  Created by Dan Kwon on 8/21/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DKRedditManager : NSObject {
    NSString *modhash;
	NSDate *lastLoginTime;
    BOOL isLoggingIn;

}


@property (nonatomic, retain) NSString *modhash;
@property (nonatomic, retain) NSDate *lastLoginTime;

+ (id)sharedRedditManager;

- (BOOL)isLoggedIn;
- (BOOL)isLoggingIn;

- (void)loginWithUsername:(NSString *)aUsername password:(NSString *)aPassword completion:(void (^)(id result, NSError *error))completionHandler;
- (void)fetchSubreddits:(void (^)(id result, NSError *error))completionHandler;

@end
