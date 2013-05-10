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
- (IBAction)leftButtonClickedWithEvent:(id)sender forEvent:(UIEvent *)event;

// select project mode
@property Boolean selectionMode;

// complete project
- (IBAction)completeProjectWasClicked:(id)sender forEvent:(UIEvent *)event;

// popup events
- (IBAction)popupBackgroundClicked:(id)sender;
- (IBAction)decreaseProjectIndent:(id)sender;
- (IBAction)increaseIndent:(id)sender;
- (IBAction)editProjectClicked:(id)sender;
- (IBAction)setAsLifeGoalClicked:(id)sender;
- (IBAction)setAsWeeklyGoalClicked:(id)sender;
- (IBAction)addNewProjectAboveClicked:(id)sender;
- (IBAction)addNewProjectBelowClicked:(id)sender;

// header
@property UIView *headerManualView;

@end
