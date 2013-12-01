//
//  BidDetailsViewController.h
//  TCEPE
//
//  Created by Raphael Araujo on 11/22/13.
//  Copyright (c) 2013 Raphael Araujo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@protocol BidDetailDelegate ;

@interface BidDetailsViewController : UIViewController<MBProgressHUDDelegate>
{
    id <BidDetailDelegate> delegate;
}

@property (nonatomic, retain) id <BidDetailDelegate> delegate;
@property (readwrite) NSString *bidID;

@end

@protocol BidDetailDelegate

- (void) didTurnBack;
- (void) bookmarkBidTapped;
@end