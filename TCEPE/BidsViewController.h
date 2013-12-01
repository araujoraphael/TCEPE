//
//  BidsViewController.h
//  TCEPE
//
//  Created by Raphael Araujo on 11/21/13.
//  Copyright (c) 2013 Raphael Araujo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "BidDetailsViewController.h"

@interface BidsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate, BidDetailDelegate>

@property (readwrite) NSString *yearValue;
@property (readwrite) NSString *judgeValue;
@property (readwrite) NSString *typeValue;
@property (readwrite) NSString *phaseValue;
@property (readwrite) NSString *statusValue;
@property (readwrite) BOOL isBacking;
@property (readwrite) BOOL areBookmarks;
@end
