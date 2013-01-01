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

#import <CoreData/CoreData.h>

@interface BSMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) BSDetailViewController *detailViewController;

@property BSDataController* dataController;

//inline editing
@property UITextField *txtField;
@property NSManagedObjectID *currentEditingItemId;

@end
