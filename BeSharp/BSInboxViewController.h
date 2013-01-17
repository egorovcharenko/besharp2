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

@interface BSInboxViewController : BSListViewController 

// popup dialog
- (IBAction)indentMinusAction:(id)sender;
- (IBAction)indentPlusAction:(id)sender;
- (IBAction)completeTaskClicked:(id)sender;
- (IBAction)markAsProjectClicked:(id)sender;
@property (strong) UIView *popupView;
@property NSManagedObject *popupLine;
@property NSIndexPath *popupIndexPath;
- (IBAction)leftButtonClicked:(id)sender;


@end
