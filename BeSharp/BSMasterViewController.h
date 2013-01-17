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
- (IBAction)markAsProjectClicked:(id)sender;
- (IBAction)leftButtonClicked:(id)sender;

@end
