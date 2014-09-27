//
//  FZSelectTwitterViewController.m
//  FlashZone
//
//  Created by Dan Kwon on 9/17/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZSelectTwitterViewController.h"

@interface FZSelectTwitterViewController ()
@property (strong, nonatomic) UITableView *twitterAccountsTable;
@property (strong, nonatomic) UILabel *lblHeader;
@end

@implementation FZSelectTwitterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Twitter";
        
    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:YES];
    CGRect frame = view.frame;
    
    self.lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 72.0f)];
    self.lblHeader.text = @"Select an account:";
    self.lblHeader.textAlignment = NSTextAlignmentCenter;
    self.lblHeader.textColor = [UIColor grayColor];
    self.lblHeader.font = [UIFont boldSystemFontOfSize:16.0f];


    self.twitterAccountsTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height) style:UITableViewStyleGrouped];
    self.twitterAccountsTable.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.twitterAccountsTable.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
    self.twitterAccountsTable.dataSource = self;
    self.twitterAccountsTable.delegate = self;
    [view addSubview:self.twitterAccountsTable];
    
    
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *imgBack = [UIImage imageNamed:@"backArrow.png"];
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setBackgroundImage:imgBack forState:UIControlStateNormal];
    btnBack.frame = CGRectMake(0.0f, 0.0f, imgBack.size.width, imgBack.size.height);
    [btnBack addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];

    [self showAlertWithtTitle:@"Select Account" message:@"We found multiple Twitter accounts associated with this device. Please select one"];

}

- (void)exit
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - UITableViewDataSource
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.lblHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 72.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.socialAccountsMgr.twitterAccounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    ACAccount *twitterAccount = self.socialAccountsMgr.twitterAccounts[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"@%@", twitterAccount.username.uppercaseString];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ACAccount *twitterAccount = self.socialAccountsMgr.twitterAccounts[indexPath.row];
    self.socialAccountsMgr.selectedTwitterAccount = twitterAccount;
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
