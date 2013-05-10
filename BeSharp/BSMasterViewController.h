//
//  BSMasterViewController.h
//  BeSharp
//
//  Created by Egor Ovcharenko on 28.12.12.
//  Copyright (c) 2012 Egor Ovcharenko. All rights reserved.
//

#import <UIKit/UIKit.h>


#import <CoreData/CoreData.h>
#import "ATSDragToReorderTableViewController.h"

#import "BSListViewController.h"

@interface BSMasterViewController : BSListViewController

// popup dialog
- (IBAction)indentMinusAction:(id)sender;
- (IBAction)indentPlusAction:(id)sender;
- (IBAction)completeTaskClicked:(id)sender;
- (IBAction)pomodoroButtonClicked:(id)sender;

// hide popup
- (IBAction)popupBackgroundButtonClicked:(id)sender;

- (IBAction)markAsGoalClicked:(id)sender;
- (IBAction)moveToProjectClicked:(id)sender;
- (IBAction)addNewTaskAbove:(id)sender;
- (IBAction)addNewTaskBelow:(id)sender;
- (IBAction)addNewTaskChild:(id)sender;

// show popup
- (IBAction)leftButtonClicked:(id)sender forEvent:(UIEvent *)event;

// parent project
@property (nonatomic) Line* parentProject;

// change project for line
@property Line* lineWithProbablyNewProject;

// mark as completed button
- (IBAction)markAsCompleted:(id)sender;

// header
@property UIView *headerManualView;


@end
