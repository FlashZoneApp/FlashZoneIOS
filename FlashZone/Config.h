//
//  Config.h
//  FlashZone
//
//  Created by Dan Kwon on 7/29/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#ifndef FlashZone_Config_h
#define FlashZone_Config_h


#define kBaseUrl @"http://flash-zone.appspot.com/"

// Social Integration
#define kTwitterAPI             @"https://api.twitter.com/1.1/"
#define kFacebookAPI            @"https://graph.facebook.com/v2.1/"
#define kFacebookAppID          @"552474471525097"
#define kFacebookPermissions    @[@"email", @"user_likes", @"user_interests"]
#define kLinkedInAPI            @"https://api.linkedin.com/v1/"
#define kLinkedInClientID       @"77clc8s96rvbxr"
#define kLinkedInClientSecret   @"bNldG6BFfJZTMPtu"
#define kLinkedInState          @"DCEEFWF45453sdffef424"
#define kGooglePlusClientID     @"434470043767-1dbtcobtt0i4kokfor9lujjthgpkp3ih.apps.googleusercontent.com"




//Colors:
#define kOrange         [UIColor colorWithRed:255.0f/255.0f green:173.0f/255.0f blue:15.0f/255.0f alpha:1.0f]
#define kFacebookBlue   @"#277dbd"
#define kTwitterBlue    @"#3fc0ec"
#define kLinkedinBlue   @"#0f83b9"
#define kGoogleRed      @"#dd4b39"
#define kRedditRed      @"#ff500f"

//update the background to be solid color hexcode. (no more transparency / translucency.  hexcodes as follows: fb: #277dbd  twitter: #3fc0ec  google+: #3fc0ec   linkedin: #0f83b9 reddit: #ff500f       email: #9d9d9d


#define kShowProfileDetailsNotification @"ShowProfileDetails"

#endif
