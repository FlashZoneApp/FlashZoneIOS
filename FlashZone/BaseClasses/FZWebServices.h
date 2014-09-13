//
//  FZWebServices.h
//  FlashZone
//
//  Created by Dan Kwon on 7/29/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FZProfile.h"

typedef void (^FZWebServiceRequestCompletionBlock)(id result, NSError *error);

@interface FZWebServices : NSObject

+ (FZWebServices *)sharedInstance;

// Profile
- (void)fetchProfileInfo:(FZProfile *)profile completionBlock:(FZWebServiceRequestCompletionBlock)completionBlock;
- (void)registerProfile:(FZProfile *)profile completionBlock:(FZWebServiceRequestCompletionBlock)completionBlock;
- (void)login:(NSDictionary *)pkg completionBlock:(FZWebServiceRequestCompletionBlock)completionBlock;
//- (void)updateProfile:(FZProfile *)profile completionBlock:(FZWebServiceRequestCompletionBlock)completionBlock;

// General
- (void)fetchWebImage:(NSString *)baseUrl withPath:(NSString *)path withParams:(NSDictionary *)params completionBlock:(FZWebServiceRequestCompletionBlock)completionBlock;

// Images:
- (void)fetchUploadString:(FZWebServiceRequestCompletionBlock)completionBlock;
- (void)uploadImage:(NSDictionary *)image toUrl:(NSString *)uploadUrl completion:(FZWebServiceRequestCompletionBlock)completionBlock;

// FlashTags
- (void)fetchCategoryList:(FZWebServiceRequestCompletionBlock)completionBlock;
- (void)fetchFlashTags:(FZWebServiceRequestCompletionBlock)completionBlock;



@end
