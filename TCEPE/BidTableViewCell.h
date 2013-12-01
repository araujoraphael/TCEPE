//
//  BidTableViewCell.h
//  TCEPE
//
//  Created by Raphael Araujo on 11/21/13.
//  Copyright (c) 2013 Raphael Araujo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BidTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIView *colorIndicatorView;
@property (nonatomic, weak) IBOutlet UILabel *typeLabel;
@property (nonatomic, weak) IBOutlet UILabel *objectLabel;
@property (nonatomic, weak) IBOutlet UILabel *yearLabel;
@property (nonatomic, weak) IBOutlet UILabel *processLabel;
@property (nonatomic, weak) IBOutlet UIButton *bookmarkedButton;


@end
