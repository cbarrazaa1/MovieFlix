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
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

// class properties
@property (strong, nonatomic) NSArray* movies;
@property (strong, nonatomic) NSArray* filteredMovies;
@property (strong, nonatomic) UIRefreshControl* refreshControl;
@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.searchBar.delegate = self;
    [self fetchMovies];
    
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
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction: ok];
            
            // show the alert window
            [self presentViewController:alert animated:YES completion:^{
            }];
            
            NSLog(@"%@", [error localizedDescription]);
        }
        else
        {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            self.movies = dataDictionary[@"results"];
            self.filteredMovies = self.movies;
            [self.collectionView reloadData];
        }
        
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
    NSDictionary* movie = self.movies[index.row];
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
        
        item.movieImage.image = nil;
        [item.movieImage setImageWithURL:actualURL];
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
@end
