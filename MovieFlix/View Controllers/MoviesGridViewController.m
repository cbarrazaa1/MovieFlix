 //
//  MoviesGridViewController.m
//  MovieFlix
//
//  Created by César Francisco Barraza on 6/28/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "MoviesGridViewController.h"
#import "MovieItem.h"
#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MoviesGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>
// control definitions
@property (weak, nonatomic) IBOutlet UICollectionView* collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar* searchBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* activityIndicator;

// class properties
@property (strong, nonatomic) NSArray* movies;
@property (strong, nonatomic) NSArray* filteredMovies;
@property (strong, nonatomic) UIRefreshControl* refreshControl;
@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set up collectionview and searchbar
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.searchBar.delegate = self;
    
    // start loading movies
    [self.activityIndicator startAnimating];
    [self fetchMovies];
    
    // refesh control setup
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.collectionView insertSubview:self.refreshControl atIndex:0];
    
    // set up Collectionview layout
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    CGFloat postersPerLine = 2;
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}

- (void)fetchMovies {
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
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
            
            // clear movies if we can't no longer get them
            self.movies = nil;
            self.filteredMovies = nil;
            NSLog(@"%@", [error localizedDescription]);
        }
        else
        {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            // set dictionary to class variable
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
    UICollectionViewCell* cell = sender;
    NSIndexPath* index = [self.collectionView indexPathForCell:cell];
    NSDictionary* movie = self.filteredMovies[index.item];
    
    // pass data
    DetailsViewController* viewController = [segue destinationViewController];
    viewController.movie = movie;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MovieItem* item = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieItem" forIndexPath:indexPath];
    NSDictionary* movie = self.filteredMovies[indexPath.row];
    
    if(movie != nil)
    {
        // crearte URL with poster path
        NSString* baseURL = @"https://image.tmdb.org/t/p/w500";
        NSString* posterURL = movie[@"poster_path"];
        NSString* fullURL = [baseURL stringByAppendingString:posterURL];
        NSURL* actualURL = [NSURL URLWithString:fullURL];
        NSURLRequest* urlRequest = [NSURLRequest requestWithURL:actualURL];
        
        // load image and provide fading animation for loading only if not cached already
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
        // predicate will be the dictionary, which contains the titles which are the actual strings we want to be filtering
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"title"] containsString:searchText];
        }];
        
        // filter the movies according to the searcbar text
        self.filteredMovies = [self.movies filteredArrayUsingPredicate:predicate];
    }
    else
    {
        // no text, reset the filter
        self.filteredMovies = self.movies;
    }
    
    // reload the data with the filter
    [self.collectionView reloadData];
}

// Allows the cancel button to appear in the search bar
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // hide cancel and clear searchbar
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    
    // reset the data, remove filter
    self.filteredMovies = self.movies;
    [self.collectionView reloadData];
    [self.searchBar resignFirstResponder];
}

- (IBAction)onTap:(id)sender {
    [self.refreshControl endRefreshing];
}

// Helper method to make sure collectionview recovers original position when refresh control disappears
- (void)endRefreshControl {
    [self.refreshControl endRefreshing];
    [self.collectionView setContentOffset:CGPointMake(0, -self.refreshControl.bounds.size.height) animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    // animate when movie is tapped, by changing the scaling of the image
    [UIView animateWithDuration:0.12 animations:^{
        cell.transform = CGAffineTransformMakeScale(1.02, 1.02);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.12 animations:^{
            cell.transform = CGAffineTransformIdentity;
        }];
    }];
}
@end
