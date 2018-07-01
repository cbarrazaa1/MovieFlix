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
// control definitions
@property (weak, nonatomic) IBOutlet UIImageView* backdropView;
@property (weak, nonatomic) IBOutlet UIImageView* posterView;
@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UILabel* dateLabel;
@property (weak, nonatomic) IBOutlet UILabel* descLabel;
@property (weak, nonatomic) IBOutlet UIScrollView* scrollView;
@property (weak, nonatomic) IBOutlet UILabel* ratingLabel;
@property (weak, nonatomic) IBOutlet UIProgressView* ratingBar;

// class properties
@property (strong, nonatomic) NSArray* trailerResults;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // URLs for different resolution backdrops
    NSString* smallBaseURL = @"https://image.tmdb.org/t/p/w200";
    NSString* largeBaseURL = @"https://image.tmdb.org/t/p/w500";
    
    // set up backdrop URLs
    NSString* backdropURL = self.movie[@"backdrop_path"];
    NSString* smallBackdropURL = [smallBaseURL stringByAppendingString:backdropURL];
    NSString* largeBackdropURL = [largeBaseURL stringByAppendingString:backdropURL];
    NSURL* actualSmallBackdropURL = [NSURL URLWithString:smallBackdropURL];
    NSURL* actualLargeBackdropURL = [NSURL URLWithString:largeBackdropURL];
    NSURLRequest* smallRequest = [NSURLRequest requestWithURL:actualSmallBackdropURL];
    NSURLRequest* largeRequest = [NSURLRequest requestWithURL:actualLargeBackdropURL];
    
    // load the backdrop
    [self.backdropView setImageWithURLRequest:smallRequest placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull smallImage)
     {
         self.backdropView.alpha = 0;
         self.backdropView.image = smallImage;
         
         // animate fade animation for low-res backdrop
         [UIView animateWithDuration:0.3 animations:^{
             self.backdropView.alpha = 1;
         } completion:^(BOOL finished) {
             // once animation is finished, start loading high-res backdrop so that it looks seamless
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
    
    // load the poster to the view
    [self.posterView setImageWithURL:actualPosterURL];
    [self.posterView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [self.posterView.layer setBorderWidth: 2.0];
    
    // set up labels
    self.titleLabel.text = self.movie[@"title"];
    self.descLabel.text = self.movie[@"overview"];
    self.dateLabel.text = self.movie[@"release_date"];
    
    // allows the scrollview to adapt according to the size of the description
    [self.descLabel sizeToFit];
    CGFloat maxHeight = self.descLabel.frame.origin.y + self.descLabel.frame.size.height + 30.0;
    self.scrollView.contentSize = CGSizeMake(self.descLabel.frame.size.width, maxHeight);
    
    // load trailer
    NSNumber* movieID = self.movie[@"id"];
    NSString* strID = [movieID stringValue];
    NSString* baseURL = @"https://api.themoviedb.org/3/movie/";
    NSString* urlWithID = [baseURL stringByAppendingString:strID];
    NSString* fullURL = [urlWithID stringByAppendingString:@"/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US"];
    NSURL *url = [NSURL URLWithString:fullURL];
    
    // set up the block that will run so that we get the trailer data
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
    
    // load ratings
    NSString* rating = self.movie[@"vote_average"];
    double dRating = [rating doubleValue];
    self.ratingLabel.text = [NSString stringWithFormat:@"%.1f/10.0", dRating];

    // change color of label and bar according to ratings
    UIColor* color = nil;
    if(dRating < 4)
    {
        color = [UIColor redColor];
    }
    else if(dRating >= 4 && dRating < 7.5)
    {
        color = [UIColor yellowColor];
    }
    else if(dRating >= 7.5)
    {
        color = [UIColor greenColor];
    }
    
    self.ratingLabel.textColor = color;
    self.ratingBar.tintColor = color;
    self.ratingBar.progress = 0;
    [self.ratingBar setProgress:(dRating / 10.0f) animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // load the first trailer available
    NSDictionary* trailer = self.trailerResults[0];
    NSString* videoKey = trailer[@"key"];
    NSString* baseYoutubeURL = @"https://www.youtube.com/watch?v=";
    NSString* youtubeURL = [baseYoutubeURL stringByAppendingString:videoKey];
    
    // pass data
    TrailerViewController* viewController = [segue destinationViewController];
    viewController.currentURL = youtubeURL;
}

- (IBAction)onTap:(id)sender {
    NSLog(@"Tap");
}

@end
