 //
//  DetailsViewController.m
//  MovieFlix
//
//  Created by César Francisco Barraza on 6/28/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TrailerViewController.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

// class properties
@property (strong, nonatomic) NSArray* trailerResults;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString* smallBaseURL = @"https://image.tmdb.org/t/p/w200";
    NSString* largeBaseURL = @"https://image.tmdb.org/t/p/w500";
    
    // set up backdrop
    NSString* backdropURL = self.movie[@"backdrop_path"];
    NSString* smallBackdropURL = [smallBaseURL stringByAppendingString:backdropURL];
    NSString* largeBackdropURL = [largeBaseURL stringByAppendingString:backdropURL];
    NSURL* actualSmallBackdropURL = [NSURL URLWithString:smallBackdropURL];
    NSURL* actualLargeBackdropURL = [NSURL URLWithString:largeBackdropURL];
    NSURLRequest* smallRequest = [NSURLRequest requestWithURL:actualSmallBackdropURL];
    NSURLRequest* largeRequest = [NSURLRequest requestWithURL:actualLargeBackdropURL];
    
    [self.backdropView setImageWithURLRequest:smallRequest placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull smallImage)
     {
         self.backdropView.alpha = 0;
         self.backdropView.image = smallImage;
         
         [UIView animateWithDuration:0.3 animations:^{
             self.backdropView.alpha = 1;
         } completion:^(BOOL finished) {
             [self.backdropView setImageWithURLRequest:largeRequest
                                      placeholderImage:smallImage
              success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull largeImage)
              {
                  self.backdropView.image = largeImage;
              }
              failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error)
              {
                  [self.backdropView setImageWithURL:actualLargeBackdropURL];
              }];
         }];
     }
    failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error)
     {
         [self.backdropView setImageWithURL:actualLargeBackdropURL];
     }];
    
    // set up poster
    NSString* posterURL = self.movie[@"poster_path"];
    NSString* fullPosterURL = [largeBaseURL stringByAppendingString:posterURL];
    NSURL* actualPosterURL = [NSURL URLWithString:fullPosterURL];
    
    [self.posterView setImageWithURL:actualPosterURL];
    [self.posterView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [self.posterView.layer setBorderWidth: 2.0];
    
    // set up labels
    self.titleLabel.text = self.movie[@"title"];
    self.descLabel.text = self.movie[@"overview"];
    self.dateLabel.text = self.movie[@"release_date"];
    
    //[self.titleLabel sizeToFit];
    [self.descLabel sizeToFit];
   // [self.dateLabel sizeToFit];
    
    CGFloat maxHeight = self.descLabel.frame.origin.y + self.descLabel.frame.size.height + 30.0;
    self.scrollView.contentSize = CGSizeMake(self.descLabel.frame.size.width, maxHeight);
    
    // load trailer
    NSNumber* movieID = self.movie[@"id"];
    NSString* strID = [movieID stringValue];
    
    NSString* baseURL = @"https://api.themoviedb.org/3/movie/";
    NSString* urlWithID = [baseURL stringByAppendingString:strID];
    NSString* fullURL = [urlWithID stringByAppendingString:@"/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US"];
    NSURL *url = [NSURL URLWithString:fullURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            self.trailerResults = dataDictionary[@"results"];
        }
    }];
    [task resume];
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
    NSDictionary* trailer = self.trailerResults[0];
    NSString* videoKey = trailer[@"key"];
    NSString* baseYoutubeURL = @"https://www.youtube.com/watch?v=";
    NSString* youtubeURL = [baseYoutubeURL stringByAppendingString:videoKey];
    
    TrailerViewController* viewController = [segue destinationViewController];
    viewController.currentURL = youtubeURL;
}

- (IBAction)onTap:(id)sender {
    NSLog(@"Tap");
}

@end
