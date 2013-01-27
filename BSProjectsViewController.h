//
//  BSProjectsViewController.h
//  BeSharp
//
//  Created by Egor Ovcharenko on 19.01.13.
//  Copyright (c) 2013 Egor Ovcharenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "ATSDragToReorderTableViewController.h"
#import "BSListViewController.h"

@interface BSProjectsViewController : BSListViewController

// popup dialog
@property (strong) UIView *popupView;
@property NSIndexPath *popupIndexPath;
- (IBAction)leftButtonClicked:(id)sender;

// select project mode
@property Boolean selectionMode;

@end
