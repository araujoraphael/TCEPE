//
//  OptionsViewController.h
//  TCEPE
//
//  Created by Raphael Araujo on 11/19/13.
//  Copyright (c) 2013 Raphael Araujo. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol OptionsDelegate;

@interface OptionsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    id <OptionsDelegate> delegate;
}

@property (nonatomic, retain) id <OptionsDelegate> delegate;

@property (readwrite) NSInteger filterId;

@end

@protocol OptionsDelegate

- (void) didSelectOptionWithIndex:(NSNumber *)index option:(NSString *)option;
@end
