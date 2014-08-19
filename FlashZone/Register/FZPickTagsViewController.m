//
//  FZPickTagsViewController.m
//  FlashZone
//
//  Created by Dan Kwon on 8/18/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZPickTagsViewController.h"

@interface FZPickTagsViewController ()
@property (strong, nonatomic) UITableView *tagsTable;
@end

@implementation FZPickTagsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:NO];
    CGRect frame = view.frame;
    view.backgroundColor = [UIColor redColor];
    
    self.tagsTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height) style:UITableViewStylePlain];
    self.tagsTable.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tagsTable.dataSource = self;
    self.tagsTable.delegate = self;
    [view addSubview:self.tagsTable];
    
    
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
                NSLog(@"Error fetching recent tweets.");
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
                    [self.tagsTable reloadData];
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
                        [self.tagsTable reloadData];
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

    if (self.profile.registrationType==FZRegistrationTypeLinkedIn){
        NSLog(@"REGISTRATION - LINKED IN");
        return;
    }

}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.profile.tags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    cell.textLabel.text = self.profile.tags[indexPath.row];
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
