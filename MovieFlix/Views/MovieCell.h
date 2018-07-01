//
//  MovieCell.h
//  MovieFlix
//
//  Created by César Francisco Barraza on 6/27/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieCell : UITableViewCell
// control definitions
@property (weak, nonatomic) IBOutlet UIImageView* movieImage;
@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UILabel* descLabel;
@end
