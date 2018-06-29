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
    NSURL* url = [NSURL URLWithString:self.currentURL];
    NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
