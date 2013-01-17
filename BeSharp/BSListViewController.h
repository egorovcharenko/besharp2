//
//  BSListViewController.h
//  
//
//  Created by Egor Ovcharenko on 17.01.13.
//
//

#import "ATSDragToReorderTableViewController.h"

@class BSDetailViewController;
@class BSDataController;
@class BSLineCell;

@interface BSListViewController : ATSDragToReorderTableViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITextFieldDelegate>

// data access
@property (strong, nonatomic) BSDetailViewController *detailViewController;
@property BSDataController* dataController;

//inline editing
@property NSManagedObjectID *currentEditingItemId;
- (IBAction)leftButtonOnCellClicked:(id)sender forEvent:(UIEvent *)event;
@property BSLineCell *currentlySelectedCell;

// new task entry
@property (weak, nonatomic) IBOutlet UIView *headerView;
- (IBAction)newTaskButtonClicked:(id)sender;
@property UITextField *theNewLineTextField;
@property UIView *headerManualView;

// popup
@property (strong) UIView *popupView;
@property NSManagedObject *popupLine;
@property NSIndexPath *popupIndexPath;
- (NSString*) popupNibName;
- (IBAction)showPopup:(UIButton*)sender;

// display cells
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end