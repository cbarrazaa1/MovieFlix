 //
//  DetailsViewController.m
//  MovieFlix
//
//  Created by César Francisco Barraza on 6/28/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // set up backdrop
    NSString* baseURL = @"https://image.tmdb.org/t/p/w500";
    NSString* backdropURL = self.movie[@"backdrop_path"];
    NSString* fullBackdropURL = [baseURL stringByAppendingString:backdropURL];
    NSURL* actualBackdropURL = [NSURL URLWithString:fullBackdropURL];
    
    [self.backdropView setImageWithURL:actualBackdropURL];
    
    // set up poster
    NSString* posterURL = self.movie[@"poster_path"];
    NSString* fullPosterURL = [baseURL stringByAppendingString:posterURL];
    NSURL* actualPosterURL = [NSURL URLWithString:fullPosterURL];
    
    [self.posterView setImageWithURL:actualPosterURL];
    [self.posterView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [self.posterView.layer setBorderWidth: 2.0];
    
    // set up labels
    self.titleLabel.text = self.movie[@"title"];
    self.descLabel.text = self.movie[@"overview"];
    self.dateLabel.text = self.movie[@"release_date"];
    
    [self.titleLabel sizeToFit];
    [self.descLabel sizeToFit];
    [self.dateLabel sizeToFit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}

@end
