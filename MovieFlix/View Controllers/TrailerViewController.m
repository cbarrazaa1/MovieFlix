//
//  TrailerViewController.m
//  MovieFlix
//
//  Created by César Francisco Barraza on 6/29/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "TrailerViewController.h"

@interface TrailerViewController ()
// control definitions
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation TrailerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    // set up url request for trailer
    NSURL* url = [NSURL URLWithString:self.currentURL];
    NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    
    // load the url into the webview
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
