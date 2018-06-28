//
//  MoviesViewController.m
//  MovieFlix
//
//  Created by César Francisco Barraza on 6/27/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>
// control definitions
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// class properties
@property (strong, nonatomic) NSArray* movies;
@property (strong, nonatomic) UIRefreshControl* refreshControl;
@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self fetchMovies];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)fetchMovies {
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            self.movies = dataDictionary[@"results"];
            [self.tableView reloadData];
        }
        
        [self.refreshControl endRefreshing];
    }];
    [task resume];
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

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    MovieCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    NSDictionary* movie = self.movies[indexPath.row];
    
    if(movie != nil)
    {
        NSString* baseURL = @"https://image.tmdb.org/t/p/w500";
        NSString* posterURL = movie[@"poster_path"];
        NSString* fullURL = [baseURL stringByAppendingString:posterURL];
        NSURL* actualURL = [NSURL URLWithString:fullURL];
        
        cell.titleLabel.text = movie[@"title"];
        cell.descLabel.text = movie[@"overview"];
        cell.movieImage.image = nil;
        [cell.movieImage setImageWithURL:actualURL];
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

@end
