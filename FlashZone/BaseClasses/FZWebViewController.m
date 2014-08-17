//
//  FZWebViewController.m
//  FlashZone
//
//  Created by Dan Kwon on 8/3/14.
//  Copyright (c) 2014 FlashZone. All rights reserved.
//

#import "FZWebViewController.h"

@interface FZWebViewController ()

@end

@implementation FZWebViewController
@synthesize theWebview;
@synthesize target;

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
    view.backgroundColor = kOrange;
    CGRect frame = view.frame;

    
    self.theWebview = [[UIWebView alloc] initWithFrame:frame];
    self.theWebview.delegate = self;
    self.theWebview.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    [view addSubview:self.theWebview];

    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.theWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:target]]];
    [self.loadingIndicator startLoading];

}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"webView shouldStartLoadWithRequest:");
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad:");
    [self.loadingIndicator stopLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"webView didFailLoadWithError:");
    [self.loadingIndicator stopLoading];
    [self showAlertWithtTitle:@"Error" message:[error localizedDescription]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
