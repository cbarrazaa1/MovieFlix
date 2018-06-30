//
//  PopularViewController.m
//  MovieFlix
//
//  Created by César Francisco Barraza on 6/29/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "PopularViewController.h"
#import "MovieItem.h"
#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface PopularViewController () <UICollectionViewDataSource,
    UICollectionViewDelegate, UISearchBarDelegate>

// control definitions
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

// class properties
@property (strong, nonatomic) NSArray* movies;
@property (strong, nonatomic) NSArray* filteredMovies;
@property (strong, nonatomic) UIRefreshControl* refreshControl;

@end

@implementation PopularViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.searchBar.delegate = self;
    [self.activityIndicator startAnimating];
    [self fetchMovies];
    
    // refesh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.collectionView insertSubview:self.refreshControl atIndex:0];
    
    // set up Collectionview layout
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    
    CGFloat postersPerLine = 3;
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    [self.refreshControl endRefreshing];
}

- (void)fetchMovies {
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/popular?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US&page=1"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session= [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil)
        {
            // create alert window
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Network Error" message:@"Could not load movies." preferredStyle:UIAlertControllerStyleAlert];
            
            // create OK button
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.activityIndicator startAnimating];
                [self fetchMovies];
            }];
            [alert addAction: ok];
            
            // show the alert window
            [self endRefreshControl];
            [self presentViewController:alert animated:YES completion:^{
            }];
            self.movies = nil;
            self.filteredMovies = nil;
            NSLog(@"%@", [error localizedDescription]);
        }
        else
        {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            self.movies = dataDictionary[@"results"];
            self.filteredMovies = self.movies;
        }
        
        [self.collectionView reloadData];
        [self.activityIndicator stopAnimating];
        [self.refreshControl endRefreshing];
    }];
    [task resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UICollectionViewCell* cell = sender;
    NSIndexPath* index = [self.collectionView indexPathForCell:cell];
    NSDictionary* movie = self.filteredMovies[index.item];
    DetailsViewController* viewController = [segue destinationViewController];
    viewController.movie = movie;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MovieItem* item = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieItem" forIndexPath:indexPath];
    NSDictionary* movie = self.filteredMovies[indexPath.item];
    
    if(movie != nil)
    {
        NSString* baseURL = @"https://image.tmdb.org/t/p/w500";
        NSString* posterURL = movie[@"poster_path"];
        NSString* fullURL = [baseURL stringByAppendingString:posterURL];
        NSURL* actualURL = [NSURL URLWithString:fullURL];
        NSURLRequest* urlRequest = [NSURLRequest requestWithURL:actualURL];
        
        [item.movieImage setImageWithURLRequest:urlRequest placeholderImage:item.movieImage.image
                    success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                        if (response)
                        {
                            item.movieImage.alpha = 0;
                            item.movieImage.image = image;
                            
                            [UIView animateWithDuration:0.8 animations:^{
                                item.movieImage.alpha = 1.0;
                            }];
                        }
                        else
                        {
                            item.movieImage.image = image;
                        }
                    }
                    failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                        
                    }];
    }
    
    return item;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredMovies.count;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0)
    {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"title"] containsString:searchText];
        }];
        self.filteredMovies = [self.movies filteredArrayUsingPredicate:predicate];
        
        NSLog(@"%@", self.filteredMovies);
    }
    else
    {
        self.filteredMovies = self.movies;
    }
    
    [self.collectionView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    self.filteredMovies = self.movies;
    [self.collectionView reloadData];
    [self.searchBar resignFirstResponder];
}

- (IBAction)onTap:(id)sender {
    [self.refreshControl endRefreshing];
}

- (void)endRefreshControl {
    [self.refreshControl endRefreshing];
    [self.collectionView setContentOffset:CGPointMake(0, -self.refreshControl.bounds.size.height) animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    [UIView animateWithDuration:0.12 animations:^{
        cell.transform = CGAffineTransformMakeScale(1.02, 1.02);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.12 animations:^{
            cell.transform = CGAffineTransformIdentity;
        }];
    }];
}
@end
