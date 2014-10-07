//
//  FZPickTagsViewController.m
//  FlashZone
//
//  Created by Dan Kwon on 8/18/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZPickTagsViewController.h"
#import "FZTagsIntroView.h"
#import "FZTagsSelectNetworkView.h"
#import "FZExploreTagsView.h"
#import "FZTagsMenuViewController.h"
#import "FZSelectedTagView.h"
#import "FZSearchCell.h"
#import "FZSelectTwitterViewController.h"
#import "FZRedditLoginViewController.h"


@interface FZPickTagsViewController ()
@property (strong, nonatomic) UIScrollView *theScrollview;
@property (strong, nonatomic) FZTagsIntroView *introSlide;
@property (strong, nonatomic) FZTagsSelectNetworkView *selectNetworkSlide;
@property (strong, nonatomic) FZExploreTagsView *exploreTagsSlide;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) NSMutableArray *allInterests; // combination of categories and subcategories
@property (strong, nonatomic) UITableView *searchTable;
@end

@implementation FZPickTagsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.categories = nil;
        self.searchResults = [NSMutableArray array];
        self.allInterests = [NSMutableArray array];
    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:NO];
    CGRect frame = view.frame;
    view.backgroundColor = kOrange;
    
    self.theScrollview = [[UIScrollView alloc] initWithFrame:frame];
    self.theScrollview.delegate = self;
    self.theScrollview.pagingEnabled = YES;
    self.theScrollview.showsHorizontalScrollIndicator = NO;
    self.theScrollview.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin);
    
    CGFloat x = 0.0f;
    self.introSlide = [[FZTagsIntroView alloc] initWithFrame:CGRectMake(x, 0.0f, frame.size.width, frame.size.height)];
    self.introSlide.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    if (self.profile.imageData)
        self.introSlide.profileIcon.image = self.profile.imageData;
    [self.introSlide.btnGotit addTarget:self action:@selector(nextSlide) forControlEvents:UIControlEventTouchUpInside];
    [self.introSlide.btnNext addTarget:self action:@selector(nextSlide) forControlEvents:UIControlEventTouchUpInside];
    [self.theScrollview addSubview:self.introSlide];
    x += self.introSlide.frame.size.width;

    self.selectNetworkSlide = [[FZTagsSelectNetworkView alloc] initWithFrame:CGRectMake(x, 0.0f, frame.size.width, frame.size.height)];
    self.selectNetworkSlide.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.selectNetworkSlide.btnNext addTarget:self action:@selector(nextSlide) forControlEvents:UIControlEventTouchUpInside];
    [self.selectNetworkSlide.btnGetStarted addTarget:self action:@selector(showTagsMenu) forControlEvents:UIControlEventTouchUpInside];
    
    for (UIButton *btn in self.selectNetworkSlide.socialIconsArray)
        [btn addTarget:self action:@selector(socialNetworkSelected:) forControlEvents:UIControlEventTouchUpInside];

    [self.theScrollview addSubview:self.selectNetworkSlide];

    
    self.theScrollview.contentSize = CGSizeMake(3*frame.size.width, 0);
    
    [view addSubview:self.theScrollview];
    
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, frame.size.height-30.0f, frame.size.width, 24.0f)];
    self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.pageControl.numberOfPages = 3;
    [view addSubview:self.pageControl];
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)fetchCategoryList
{
    if (self.categories) // already done. don't do it again.
        return;

    [[FZWebServices sharedInstance] fetchCategoryList:^(id result, NSError *error){
        if (error){
            
        }
        else{
            NSDictionary *results = (NSDictionary *)result;
            NSDictionary *categoryList = results[@"categorylist"];
            self.categories = categoryList[@"categories"];
            NSLog(@"CATEGORIES: %@", [self.categories description]);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat x = self.selectNetworkSlide.frame.origin.x+self.selectNetworkSlide.frame.size.width;

                self.exploreTagsSlide = [FZExploreTagsView viewWithCategories:self.categories withFrame:CGRectMake(x, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
                self.exploreTagsSlide.searchField.delegate = self;
                self.exploreTagsSlide.autoresizingMask = UIViewAutoresizingFlexibleHeight;
                self.exploreTagsSlide.tagsScrollview.delegate = self;
                
                for (UIButton *btn in self.exploreTagsSlide.buttonsArray)
                    [btn addTarget:self action:@selector(categorySelected:) forControlEvents:UIControlEventTouchUpInside];
                
                for (UIButton *btn in self.exploreTagsSlide.socialIconsArray)
                    [btn addTarget:self action:@selector(socialNetworkSelected:) forControlEvents:UIControlEventTouchUpInside];

                
                [self.theScrollview addSubview:self.exploreTagsSlide];
                
                CGFloat y = (self.view.frame.size.height > 500)? 104.0f : 94.0f;
                self.searchTable = [[UITableView alloc] initWithFrame:CGRectMake(x, y, self.view.frame.size.width, self.view.frame.size.height-y) style:UITableViewStylePlain];
                self.searchTable.dataSource = self;
                self.searchTable.delegate = self;
                self.searchTable.backgroundColor = [UIColor whiteColor];
                self.searchTable.alpha = 0.0f;
                self.searchTable.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
                [self.searchTable setSeparatorInset:UIEdgeInsetsZero];
                [self.theScrollview addSubview:self.searchTable];
                
                [self fetchGeneralInterests];
            });
        }
        
    }];
}

- (void)fetchGeneralInterests
{
    [[FZWebServices sharedInstance] fetchInterests:^(id result, NSError *error){
        if (error){
            
        }
        else{
            NSDictionary *results = (NSDictionary *)result;
            NSString *confirmation = results[@"confirmation"];
            if ([confirmation isEqualToString:@"success"]){
                
                NSArray *interests = results[@"interests"];
                for (int i=0; i<interests.count; i++){
                    NSDictionary *interest = (NSDictionary *)interests[i];
//                    NSLog(@"INTEREST: %@", interest);
                    NSString *name = [interest[@"name"] lowercaseString];
                    if ([self.allInterests containsObject:name]==NO)
                        [self.allInterests addObject:name];
                    
                    NSString *category = [interest[@"category"] lowercaseString];
                    if ([self.allInterests containsObject:category]==NO)
                        [self.allInterests addObject:category];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"ALL INTEREST: %@", [self.allInterests description]);
                });
            }
            else{
                [self showAlertWithtTitle:@"Error" message:results[@"message"]];
            }
            
            
        }
        
    }];

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.profile.suggestedTags.count > 0){
        [self fetchCategoryList];
        return;
    }
    
    
    if (self.profile.registrationType==FZRegistrationTypeEmail){
        NSLog(@"REGISTRATION - EMAIL");
        [self fetchCategoryList];
        return;
    }
    
    if (self.profile.registrationType==FZRegistrationTypeFacebook){
        NSLog(@"REGISTRATION - FACEBOOK");
        
        [self.socialAccountsMgr requestFacebookLikes:^(id result, NSError *error){
            if (error){
                NSLog(@"Error fetching recent likes.");
                return;
            }
            
            NSDictionary *results = (NSDictionary *)result;
            NSArray *likes = results[@"data"];
            if (likes){
                for (int i=0; i<likes.count; i++) {
                    NSDictionary *likeInfo = likes[i];
                    if (likeInfo[@"name"])
                        [self.profile.suggestedTags addObject:@{@"name":likeInfo[@"name"], @"id":@"-1"}];
                    
                    NSArray *categoryList = (NSArray *)likeInfo[@"category_list"];
                    for (NSDictionary *categoryInfo in categoryList) {
                        NSString *categoryName = categoryInfo[@"name"];
                        if (categoryName != nil)
                            [self.profile.suggestedTags addObject:@{@"name":categoryName, @"id":@"-1"}];
                        
                    }
                }
            }
            [self fetchCategoryList];
        }];
        
        return;
    }

    if (self.profile.registrationType==FZRegistrationTypeTwitter){ // fetch most recent tweets
        NSLog(@"REGISTRATION - TWITTER");
        
        [self.socialAccountsMgr fetchRecentTweets:self.socialAccountsMgr.selectedTwitterAccount completionBlock:^(id result, NSError *error){
            if (error){
                NSLog(@"Error fetching recent tweets.");
                return;
            }
            
            NSArray *tweets = (NSArray *)result;
            NSMutableArray *tags = [NSMutableArray array];
            for (NSDictionary *tweet in tweets) {
                NSDictionary *entities = tweet[@"entities"];
                if (entities==nil)
                    continue;
                
                NSArray *hashtags = entities[@"hashtags"];
                if (hashtags==nil)
                    continue;
                
                for (NSDictionary *hashtag in hashtags) {
                    NSString *t = hashtag[@"text"];
                    if ([tags containsObject:t]==NO){
                        [tags addObject:t];
                        NSLog(@"HASH TAG: %@", t);
                    }
                }
            }
            
            for (NSString *tag in tags)
                [self.profile.suggestedTags addObject:@{@"name":tag, @"id":@"-1"}];
            
//            NSLog(@"SUGGESTED TAGS: %@", [self.profile.suggestedTags description]);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.allInterests.count == 0)
                    [self fetchCategoryList];
                else
                    [self showTagsMenu:NO];
            });
            
        }];
        
        return;
    }

    if (self.profile.registrationType==FZRegistrationTypeGoogle){
        NSLog(@"REGISTRATION - GOOGLE");
        [self fetchCategoryList];
        return;
    }

    [self fetchCategoryList];
    // linkedIn and reddit automatically returns interests on sign in so it is parsed on registration - no need to do it here

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.introSlide animate];
}

- (void)dismissKeyboard:(UIGestureRecognizer *)tap
{
    NSLog(@"dismissKeyboard:");
    [self.exploreTagsSlide.searchField resignFirstResponder];
}



- (void)nextSlide
{
//    NSLog(@"NEXT SLIDE");
    CGFloat x = self.theScrollview.contentOffset.x;
    x += self.theScrollview.frame.size.width;
    
    [self.theScrollview setContentOffset:CGPointMake(x, self.theScrollview.contentOffset.y) animated:YES];
    
    int page = (int)(self.theScrollview.contentOffset.x/self.theScrollview.frame.size.width);
    self.pageControl.currentPage = page;
    if (page==2)
        self.theScrollview.scrollEnabled = NO;

}

- (void)showTagsMenu
{
    [self showTagsMenu:YES];
    
}

- (void)showTagsMenu:(BOOL)showNext
{
    FZTagsMenuViewController *tagsMenuVc = [[FZTagsMenuViewController alloc] init];
    tagsMenuVc.backgroundImage = [self.view screenshot];
    [self.navigationController pushViewController:tagsMenuVc animated:NO];
    [self.loadingIndicator stopLoading];

    if (showNext)
        [self performSelector:@selector(nextSlide) withObject:nil afterDelay:1.0f];
}

- (void)categorySelected:(UIButton *)btn
{
    NSLog(@"categorySelected: %d", (int)btn.tag);
    
    btn.titleLabel.alpha = 0.0f;
    UIView *snapshot = [btn snapshotViewAfterScreenUpdates:YES];
    snapshot.center = [self.exploreTagsSlide.tagsScrollview convertPoint:btn.center toView:self.view];
    [self.view addSubview:snapshot];
    
    UILabel *lblCategory = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btn.frame.size.width, 22.0f)];
    lblCategory.center = snapshot.center;
    lblCategory.textColor = [UIColor whiteColor];
    lblCategory.textAlignment = NSTextAlignmentCenter;
    lblCategory.font = [UIFont boldSystemFontOfSize:14.0f];
    lblCategory.text = btn.titleLabel.text;
    [self.view addSubview:lblCategory];
    
    btn.alpha = 0.0f;
    
    [UIView animateWithDuration:0.20f
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         snapshot.transform = CGAffineTransformMakeScale(8.0f, 8.0f);
                         snapshot.alpha = 0.95f;
                         lblCategory.transform = CGAffineTransformMakeScale(3.0f, 3.0f);
                     }
                     completion:^(BOOL finished){
                         
                         [UIView animateWithDuration:0.20f
                                               delay:0
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              lblCategory.transform = CGAffineTransformIdentity;
                                              lblCategory.center = CGPointMake(0.5f*self.view.frame.size.width, 36.0f);
                                          }
                                          completion:^(BOOL finished){
                                              btn.alpha = 1.0f;
                                              btn.titleLabel.alpha = 1.0f;
                                              
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  FZTagsMenuViewController *tagsMenuVc = [[FZTagsMenuViewController alloc] initWithCategory:btn.titleLabel.text];
                                                  tagsMenuVc.screenColor = btn.backgroundColor;
                                                  tagsMenuVc.useSocialNetwork = NO;
                                                  tagsMenuVc.backgroundImage = [snapshot screenshot];
                                                  [self.navigationController pushViewController:tagsMenuVc animated:NO];
                                                  [snapshot performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0f];
                                                  
                                                  [lblCategory performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0f];

                                              });
                                          }];
                     }];
    
}

- (void)socialNetworkSelected:(UIButton *)btn
{
    int tag = (int)btn.tag;
    NSLog(@"socialNetworkSelected: %d", tag);
    
    if (tag==1000){ // facebook
        if (self.profile.registrationType == FZRegistrationTypeFacebook){
            [self showTagsMenu];
            return;
        }
        
        // Request Access - this would happen if the user registered via email/twitter/etc then decided to use FB:
        [self.loadingIndicator startLoading];
        [self.socialAccountsMgr requestFacebookAccess:kFacebookPermissions completionBlock:^(id result, NSError *error){
            
            if (error){
                [self.loadingIndicator stopLoading];
                [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
                return;
            }
            
            NSLog(@"FACEBOOK ACCESS GRANTED!!");
            [self.profile getFacebookInfo:^(BOOL success, NSError *error){
                if (error){
                    [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
                    return;
                }
                
                
                [self.socialAccountsMgr requestFacebookLikes:^(id result, NSError *error){
                    if (error){
                        NSLog(@"Error fetching recent likes.");
                        return;
                    }
                    
                    NSDictionary *results = (NSDictionary *)result;
                    NSArray *likes = results[@"data"];
                    if (likes){
                        [self.profile.suggestedTags removeAllObjects];
                        for (int i=0; i<likes.count; i++) {
                            NSDictionary *likeInfo = likes[i];
                            if (likeInfo[@"name"])
                                [self.profile.suggestedTags addObject:@{@"name":likeInfo[@"name"], @"id":@"-1"}];
                            
                            NSArray *categoryList = (NSArray *)likeInfo[@"category_list"];
                            for (NSDictionary *categoryInfo in categoryList) {
                                NSString *categoryName = categoryInfo[@"name"];
                                if (categoryName != nil)
                                    [self.profile.suggestedTags addObject:@{@"name":categoryName, @"id":@"-1"}];
                                
                            }
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.loadingIndicator stopLoading];
                        [self showTagsMenu:NO];
                    });
                }];
                
            }];
        }];
    }
    

    if (tag==1001){ // twitter
        if ([self.profile.twitterId isEqualToString:@"none"]==NO){
            [self showTagsMenu:NO];
            return;
        }

        
        [self.socialAccountsMgr requestTwitterAccess:^(id result, NSError *error){
            if (error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
                });
                return;
            }
            
            NSArray *twitterAccounts = (NSArray *)result;
            if (twitterAccounts.count == 0) {
                NSLog(@"No Twitter Acccounts found.");
                return;
            }
            
            if (twitterAccounts.count > 1){ // multiple accounts - select one
                dispatch_async(dispatch_get_main_queue(), ^{
                    FZSelectTwitterViewController *selectTwitterVc = [[FZSelectTwitterViewController alloc] init];
                    UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:selectTwitterVc];
                    navCtr.navigationBar.barTintColor = kOrange;
                    [self presentViewController:navCtr animated:YES completion:^{
                        [self.profile.suggestedTags removeAllObjects];
                        self.profile.registrationType = FZRegistrationTypeTwitter;
                        [self.loadingIndicator startLoading];
                    }];
                });
                
                return;
            }
            
            // only one account - use it:
            ACAccount *twitterAccount = self.socialAccountsMgr.twitterAccounts[0];
            [self.profile requestTwitterProfileInfo:twitterAccount completion:^(BOOL success, NSError *error){
                [self.socialAccountsMgr fetchRecentTweets:twitterAccount completionBlock:^(id result, NSError *error){
                    if (error){
                        NSLog(@"Error fetching recent tweets.");
                        return;
                    }
                    
                    [self.profile.suggestedTags removeAllObjects];
                    NSArray *tweets = (NSArray *)result;
                    NSMutableArray *tags = [NSMutableArray array];
                    for (NSDictionary *tweet in tweets) {
                        NSDictionary *entities = tweet[@"entities"];
                        if (entities==nil)
                            continue;
                        
                        NSArray *hashtags = entities[@"hashtags"];
                        if (hashtags==nil)
                            continue;
                        
                        for (NSDictionary *hashtag in hashtags) {
                            NSString *t = hashtag[@"text"];
                            if ([tags containsObject:t]==NO){
                                [tags addObject:t];
                                NSLog(@"HASH TAG: %@", t);
                            }
                        }
                    }
                    
                    for (NSString *tag in tags)
                        [self.profile.suggestedTags addObject:@{@"name":tag, @"id":@"-1"}];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showTagsMenu];
                    });
                    
                }];
                
            }];
            
            
            
        }];

        
    }

    if (tag==1002){ // google
        if (self.profile.registrationType==FZRegistrationTypeGoogle){
            [self showTagsMenu:NO];
            return;
        }
        
        
        [self.loadingIndicator startLoading];
        [self.socialAccountsMgr requestGooglePlusAccess:@[@"profile"] completion:^(id result, NSError *error){
            if (error){
                [self.loadingIndicator stopLoading];
                NSLog(@"GOOGLE PLUS LOGIN FAILED");
                return;
            }
            
            GTMOAuth2Authentication *auth = (GTMOAuth2Authentication *)result;
            
            [self.profile requestGooglePlusInfo:auth completion:^(id result, NSError *error){
                if (error)
                    return;
                
                [self.profile.suggestedTags removeAllObjects];
                GTLPlusPerson *person = (GTLPlusPerson *)result;
                if (person.occupation){
                    [self.profile.suggestedTags addObject:@{@"name":person.occupation, @"id":@"-1"}];
                }
                
                if (person.skills){
                    NSArray *skills = [person.skills componentsSeparatedByString:@","];
                    for (int i=0; i<skills.count; i++) {
                        NSString *skill = skills[i];
                        skill = [skill stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        [self.profile.suggestedTags addObject:@{@"name":skill, @"id":@"-1"}];
                    }
                }
                
                self.profile.registrationType = FZRegistrationTypeGoogle;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.loadingIndicator stopLoading];
                    [self showTagsMenu:NO];
                });
                
            }];
        }];


        
    }

    if (tag==1003){ // linkedin
        if (self.profile.registrationType==FZRegistrationTypeLinkedIn){
            [self showTagsMenu:NO];
            return;
        }
        
        
        [self.loadingIndicator startLoading];
        [self.socialAccountsMgr requestLinkedInAccess:@[@"r_fullprofile", @"r_network"] fromViewController:self completionBlock:^(id result, NSError *error){
            [self.loadingIndicator stopLoading];
            
            
            if (error){
                [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
                return;
            }
            
            [self.profile.suggestedTags removeAllObjects];
            NSDictionary *linkedInInfo = (NSDictionary *)result;
            if (linkedInInfo[@"industry"]){
                NSString *industry = linkedInInfo[@"industry"];
                [self.profile.suggestedTags addObject:@{@"name":industry, @"id":@"-1"}];
            }
            
            if (linkedInInfo[@"interests"]){
                NSString *interests = linkedInInfo[@"interests"]; // comma separated string
                NSArray *a = [interests componentsSeparatedByString:@","];
                
                for (int i=0; i<a.count; i++){
                    NSString *interest = a[i];
                    interest = [interest stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    [self.profile.suggestedTags addObject:@{@"name":interest, @"id":@"-1"}];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showTagsMenu:NO];
            });
            
        }];
        
        
    }

    if (tag==1004){ // reddit
        if (self.profile.registrationType==FZRegistrationTypeReddit){
            [self showTagsMenu:NO];
            return;
        }
        
        
        FZRedditLoginViewController *redditSignInVc = [[FZRedditLoginViewController alloc] init];
        UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:redditSignInVc];
        navCtr.navigationBar.barTintColor = kOrange;
        navCtr.navigationBar.tintColor = [UIColor whiteColor];
        [self presentViewController:navCtr animated:YES completion:^{
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(showTagsMenu:)
                                                         name:kShowProfileDetailsNotification
                                                       object:nil];
        }];

        
    }

}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (self.searchResults.count==0) ? 1 : self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    FZSearchCell *cell = (FZSearchCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil){
        cell = [[FZSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell.btnPlus addTarget:self action:@selector(selectTag:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    cell.textLabel.alpha = 1.0f;

    if (self.searchResults.count == 0){
        if (self.exploreTagsSlide.searchField.text.length > 0){
            cell.btnPlus.alpha = 1.0f;
            cell.textLabel.text = [NSString stringWithFormat:@"Add \"%@\"", self.exploreTagsSlide.searchField.text];
        }
        else{
            cell.btnPlus.alpha = 0.0f;
            cell.textLabel.text = @"";
        }
        
        return cell;
    }
    
    cell.btnPlus.alpha = 1.0f;
    cell.btnPlus.tag = 1000+indexPath.row;
    cell.textLabel.text = [NSString stringWithFormat:@"#%@", self.searchResults[indexPath.row]];
    return cell;
}

- (void)selectTag:(UIButton *)btn
{
    NSLog(@"selectTag: %d", btn.tag);
    int row = btn.tag-1000;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    
    UITableViewCell *cell = [self.searchTable cellForRowAtIndexPath:indexPath];
    cell.textLabel.alpha = 0.0f;
    UIView *iconPlus = [cell.contentView viewWithTag:1000];
    iconPlus.alpha = 0;
    
    FZSelectedTagView *cellCopy = [[FZSelectedTagView alloc] initWithFrame:CGRectMake(0.0f, 0.0, self.searchTable.frame.size.width, 44.0f)];
    
    NSString *selectedTag = (self.searchResults.count > 0) ? self.searchResults[indexPath.row] : [NSString stringWithFormat:@"Add \"%@\"", self.exploreTagsSlide.searchField.text];
    cellCopy.lblTitle.text = selectedTag;
    
    if (self.searchResults.count==0)
        [self.profile.tags addObject:self.exploreTagsSlide.searchField.text];
    else
        [self.profile.tags addObject:selectedTag];
    
    
    NSLog(@"CURRENT TAGs: %@", [self.profile.tags description]);
    
    CGPoint center = [self.view convertPoint:cell.center fromView:self.searchTable];
    center.x -= 160.0f;
    cellCopy.center = center;
    [self.view addSubview:cellCopy];
    
    [UIView animateWithDuration:0.35f
                          delay:0.1f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         cellCopy.layer.anchorPoint = CGPointMake(0, 0.5); // hinge around the left edge
                         CATransform3D leftTransform = CATransform3DMakeScale(1, 8, 1);
                         leftTransform.m34 = -1.0f/500; //dark magic to set the 3D perspective
                         leftTransform = CATransform3DRotate(leftTransform, -M_PI_2, 0, 1, 0); //rotate 90 degrees about the Y axis
                         cellCopy.layer.transform = leftTransform;
                     }
                     completion:^(BOOL finished){
                         if (self.searchResults.count > 0){
                             [self.searchResults removeObjectAtIndex:indexPath.row];
                             if (self.searchResults.count > 0){
                                 [self.searchTable beginUpdates];
                                 [self.searchTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                 [self.searchTable endUpdates];
                             }
                             else{
                                 self.exploreTagsSlide.searchField.text = @"";
                             }
                             
                             [self.searchTable reloadData]; // have to reload here in order to reset tag values of cell buttons

                         }
                         else{
                             self.exploreTagsSlide.searchField.text = @"";
                             [self.searchTable reloadData];
                         }

                         
                     }];
    
}

- (void)updateSearchResults
{
    [self.searchResults removeAllObjects];
    NSString *searchTerm = [self.exploreTagsSlide.searchField.text lowercaseString];
    if (searchTerm.length==0){
        [self.searchTable reloadData];
        return;
    }
    
    
    for (NSString *interest in self.allInterests) {
        if ([interest hasPrefix:searchTerm]){
            if ([self.searchResults containsObject:interest]==NO)
                [self.searchResults addObject:interest];
        }
    }
    
    [self.searchTable reloadData];
}



#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.searchTable.alpha = 0.90f;
    [self.searchTable reloadData];
    
    
    CGRect frame = self.searchTable.frame;
    frame.origin.y = self.view.frame.size.height;
    self.searchTable.frame = frame;
    
    
    [UIView animateWithDuration:0.75f
                          delay:0
         usingSpringWithDamping:0.75f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.searchTable.frame;
                         frame.origin.y = (self.view.frame.size.height > 500)? 104.0f : 94.0f;
                         self.searchTable.frame = frame;

                         
                     }
                     completion:NULL];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self performSelector:@selector(updateSearchResults) withObject:nil afterDelay:0.05f];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    NSLog(@"scrollViewWillBeginDragging:");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.exploreTagsSlide.searchField resignFirstResponder];
//    NSLog(@"scrollViewDidScroll: %.2f", scrollView.contentOffset.y);
    
    if (scrollView.contentOffset.y >= -100.0f)
        return;
    
    [UIView animateWithDuration:0.5f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.searchTable.frame;
                         frame.origin.y = self.view.frame.size.height;
                         self.searchTable.frame = frame;
                         
                     }
                     completion:^(BOOL finished){
                         self.searchTable.alpha = 0.0f;
                         
                         CGRect frame = self.searchTable.frame;
                         CGFloat y = (self.view.frame.size.height > 500)? 104.0f : 94.0f;
                         frame.origin.y = y;
                         self.searchTable.frame = frame;
                     }];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

//    NSLog(@"scrollViewDidEndDecelerating: %.2f", scrollView.contentOffset.x);
    
    if ([scrollView isEqual:self.theScrollview]==NO){
        return;
    }
    

    
    int page = (int)(scrollView.contentOffset.x/scrollView.frame.size.width);
    self.pageControl.currentPage = page;
    if (page==2)
        self.theScrollview.scrollEnabled = NO;
}







- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
