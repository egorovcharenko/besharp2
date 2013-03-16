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
@class Line;

@protocol LineSelectionDelegate
-(void) selectedLine:(Line*)selectedLine;
@end

@interface BSListViewController : ATSDragToReorderTableViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITextFieldDelegate, LineSelectionDelegate>{
    //id <LineSelectionDelegate> lineSelectedDelegate;
}

// data access
@property (strong, nonatomic) BSDetailViewController *detailViewController;
@property BSDataController* dataController;
// cache
@property NSFetchedResultsController *fetchResultsController;
- (void)setDataController;
- (void)initFetchController;

//inline editing
@property NSManagedObjectID *currentEditingItemId;
- (IBAction)leftButtonOnCellClicked:(id)sender forEvent:(UIEvent *)event;
@property BSLineCell *currentlySelectedCell;

// new task entry
@property (weak, nonatomic) IBOutlet UIView *headerView;
- (IBAction)newTaskButtonClicked:(id)sender;
@property UITextField *theNewLineTextField;
@property UIView *footerManualView;
-(NSInteger) leftShift;

// popup
@property (strong) UIView *popupView;
@property Line *popupLine;
@property NSIndexPath *popupIndexPath;
- (NSString*) popupNibName;
- (IBAction)showPopup:(UIButton*)sender;
- (void)rememberClickedRow:(UIButton *)sender;

// display cells
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

// parent project
- (Line*) getAParentProject;

// virtual methods
- (NSInteger) getLineType;
- (Line*) getLine:(NSIndexPath *)indexPath;

// selection delegate
@property (retain, nonatomic) id <LineSelectionDelegate> lineSelectedDelegate;

@end
