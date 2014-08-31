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


@interface FZPickTagsViewController ()
@property (strong, nonatomic) NSMutableArray *tagsMenu;
@property (strong, nonatomic) UIScrollView *theScrollview;
@property (strong, nonatomic) FZTagsIntroView *introSlide;
@property (strong, nonatomic) FZTagsSelectNetworkView *selectNetworkSlide;
@property (strong, nonatomic) FZExploreTagsView *exploreTagsSlide;
@end

@implementation FZPickTagsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tagsMenu = [NSMutableArray array];
        
    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:NO];
    CGRect frame = view.frame;
    view.backgroundColor = [UIColor redColor];
    
    self.theScrollview = [[UIScrollView alloc] initWithFrame:frame];
    self.theScrollview.delegate = self;
    self.theScrollview.pagingEnabled = YES;
    self.theScrollview.showsHorizontalScrollIndicator = NO;
    self.theScrollview.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin);
    
    CGFloat x = 0.0f;
    self.introSlide = [[FZTagsIntroView alloc] initWithFrame:CGRectMake(x, 0.0f, frame.size.width, frame.size.height)];
    self.introSlide.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.introSlide.btnGotit addTarget:self action:@selector(nextSlide) forControlEvents:UIControlEventTouchUpInside];
    [self.introSlide.btnNext addTarget:self action:@selector(nextSlide) forControlEvents:UIControlEventTouchUpInside];
    [self.theScrollview addSubview:self.introSlide];
    x += self.introSlide.frame.size.width;

    self.selectNetworkSlide = [[FZTagsSelectNetworkView alloc] initWithFrame:CGRectMake(x, 0.0f, frame.size.width, frame.size.height)];
    self.selectNetworkSlide.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.selectNetworkSlide.btnNext addTarget:self action:@selector(nextSlide) forControlEvents:UIControlEventTouchUpInside];
    [self.selectNetworkSlide.btnGetStarted addTarget:self action:@selector(showTagsMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.theScrollview addSubview:self.selectNetworkSlide];
    x += self.selectNetworkSlide.frame.size.width;

    
    self.exploreTagsSlide = [[FZExploreTagsView alloc] initWithFrame:CGRectMake(x, 0.0f, frame.size.width, frame.size.height)];
    self.exploreTagsSlide.theScrollview.delegate = self;
    self.exploreTagsSlide.searchField.delegate = self;
    self.exploreTagsSlide.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.theScrollview addSubview:self.exploreTagsSlide];

    
    self.theScrollview.contentSize = CGSizeMake(3*frame.size.width, 0);
    
    [view addSubview:self.theScrollview];
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.profile.registrationType==FZRegistrationTypeEmail){
        NSLog(@"REGISTRATION - EMAIL");
        
        return;
    }
    
    if (self.profile.registrationType==FZRegistrationTypeFacebook){
        NSLog(@"REGISTRATION - FACEBOOK");
        
        [self.socialAccountsMgr requestFacebookLikes:^(id result, NSError *error){
            if (error){
                NSLog(@"Error fetching recent likes.");
            }
            else{
                NSDictionary *results = (NSDictionary *)result;
                NSArray *likes = results[@"data"];
                if (likes){
                    for (int i=0; i<likes.count; i++) {
                        NSDictionary *likeInfo = likes[i];
                        NSArray *categoryList = (NSArray *)likeInfo[@"category_list"];
                        for (NSDictionary *categoryInfo in categoryList) {
                            NSString *categoryName = categoryInfo[@"name"];
                            if (categoryName != nil){
                                if ([self.profile.tags containsObject:categoryName]==NO)
                                    [self.profile.tags addObject:categoryName];
                            }
                        }
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.tagsTable reloadData];
                });
                

            }
        }];
        
        return;
    }

    if (self.profile.registrationType==FZRegistrationTypeTwitter){ // fetch most recent tweets
        NSLog(@"REGISTRATION - TWITTER");
        
        [self.socialAccountsMgr fetchRecentTweets:self.socialAccountsMgr.selectedTwitterAccount completionBlock:^(id result, NSError *error){
            if (error){
                NSLog(@"Error fetching recent tweets.");
            }
            else{
                NSArray *tweets = (NSArray *)result;
                
                for (NSDictionary *tweet in tweets) {
                    NSDictionary *entities = tweet[@"entities"];
                    if (entities==nil)
                        continue;
                    
                    NSArray *hashtags = entities[@"hashtags"];
                    if (hashtags==nil)
                        continue;
                    
                    for (NSDictionary *hashtag in hashtags) {
                        NSString *t = hashtag[@"text"];
                        NSLog(@"HASH TAG: %@", t);
                        if ([self.profile.tags containsObject:t]==NO)
                            [self.profile.tags addObject:t];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self.tagsTable reloadData];
                    });
                }
            }
        }];
        
        return;
    }

    if (self.profile.registrationType==FZRegistrationTypeGoogle){
        NSLog(@"REGISTRATION - GOOGLE");
        return;
    }

    // linkedIn automatically returns interests on sign in so it is parsed on registration
    if (self.profile.registrationType==FZRegistrationTypeLinkedIn){
        NSLog(@"REGISTRATION - LINKED IN");
        return;
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.introSlide animate];
    
    
}

- (void)nextSlide
{
    NSLog(@"NEXT SLIDE");
    
    CGFloat x = self.theScrollview.contentOffset.x;
    x += self.theScrollview.frame.size.width;
    
    [self.theScrollview setContentOffset:CGPointMake(x, self.theScrollview.contentOffset.y) animated:YES];
}

- (void)showTagsMenu
{
    NSLog(@"SHOW TAGS MENU");

    FZTagsMenuViewController *tagsMenuVc = [[FZTagsMenuViewController alloc] init];
    tagsMenuVc.backgroundImage = [self.view screenshot];
    [self.navigationController pushViewController:tagsMenuVc animated:NO];
    
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.exploreTagsSlide.searchField resignFirstResponder];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
