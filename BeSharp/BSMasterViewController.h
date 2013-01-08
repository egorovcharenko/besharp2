//
//  BSMasterViewController.h
//  BeSharp
//
//  Created by Egor Ovcharenko on 28.12.12.
//  Copyright (c) 2012 Egor Ovcharenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BSDetailViewController;
@class BSDataController;
@class BSLineCell;

#import <CoreData/CoreData.h>

@interface BSMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textBoxNewTask;

@property (strong, nonatomic) BSDetailViewController *detailViewController;

@property BSDataController* dataController;

@property BSLineCell *currentlySelectedCell;

//inline editing
@property NSManagedObjectID *currentEditingItemId;
- (IBAction)leftButtonOnCellClicked:(id)sender forEvent:(UIEvent *)event;

// popup dialog
- (IBAction)indentMinusAction:(id)sender;
- (IBAction)indentPlusAction:(id)sender;
@property (strong) UIView *popupView;
@property NSManagedObject *popupLine;
@property NSIndexPath *popupIndexPath;

@end
