//
//  BSListViewController.m
//
//
//  Created by Egor Ovcharenko on 17.01.13.
//
//

#import "BSListViewController.h"

#import "BSDataController.h"

#import "Line.h"
#import "BSLineCell.h"

#import "consts.h"

#import "IIViewDeckController.h"

@implementation BSListViewController

@synthesize fetchResultsController;
@synthesize lineSelectedDelegate;
@synthesize footerManualView;

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(self.footerManualView == nil) {
        // positions
        int topShift = 13;
        
        
        //allocate the view if it doesn't exist yet
        footerManualView  = [[UIView alloc] init];
        
        // get global width
        CGFloat width = CGRectGetWidth(self.view.bounds);
        
        // set stretchable background image
        UIEdgeInsets edge = UIEdgeInsetsMake(57, 13, 57, 13);
        UIImage *tasks_top = [UIImage imageNamed:@"new_task_background.png"];
        UIImage *stretchableImage = [tasks_top resizableImageWithCapInsets:edge];
        
        UIImageView* top_back = [[UIImageView alloc] initWithFrame:CGRectMake([self leftShift], 0, width - [self leftShift], footerHeight)];
        top_back.image = stretchableImage;

        // new entry field
        self.theNewLineTextField = [[UITextField alloc] initWithFrame:CGRectMake([self leftShift] + 15, topShift+3, width - [self leftShift] - 65, 34)];
        [self.theNewLineTextField setFont:[UIFont fontWithName:@"Helvetica" size:20]];
        
        self.theNewLineTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.theNewLineTextField.returnKeyType = UIReturnKeyDone;
        self.theNewLineTextField.delegate = self;
        self.theNewLineTextField.borderStyle = UITextBorderStyleNone;
        if ([self getLineType] == 2){
            // for projects use another text
            self.theNewLineTextField.placeholder = @"Type new project here";
        }
        else
        {
            self.theNewLineTextField.placeholder = @"Type new task here";
        }
        // add entry button
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [addButton setFrame:CGRectMake(self.theNewLineTextField.frame.origin.x + self.theNewLineTextField.frame.size.width + 5,
                                       topShift + 1, 28, 28)];
        [addButton setBackgroundImage:[UIImage imageNamed:@"new_task_button.png"] forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(newTaskButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [footerManualView addSubview:top_back];
        [footerManualView addSubview:self.theNewLineTextField];
        [footerManualView addSubview:addButton];
    }
    
    //return the view for the footer
    return footerManualView;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // save changes to DB
    NSManagedObjectID *editedId = self.currentEditingItemId;
    
    if (editedId != nil){
        [self.dataController saveLine:editedId withText:self.currentlySelectedCell.textFieldForEdit.text];
        
        self.currentlySelectedCell.textFieldForEdit.hidden = YES;
        self.currentlySelectedCell.textLabel.hidden = NO;
        self.currentlySelectedCell.textLabel.text = self.currentlySelectedCell.textFieldForEdit.text;
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self.dataController moveLineFrom:fromIndexPath.row to:toIndexPath.row];
}

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)setDataController
{
    // data controller
    if (self.dataController == nil){
        self.dataController = [[BSDataController alloc]initWithAppDelegate:(BSAppDelegate*)[[UIApplication sharedApplication] delegate] fetchedControllerDelegate:self];
    }
}

- (void)initFetchController
{
    // init fetch controller
    self.fetchResultsController = [self.dataController getAllLinesFromProject:[self getAParentProject] lineType:[self getLineType]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    // setup buttons on top
    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //self.navigationItem.rightBarButtonItem = addButton;
    
    [self setDataController];
    // top entry of new task button
    self.theNewLineTextField.delegate = self;
    
    // nothing is being edited
    self.currentEditingItemId = nil;
    
    [self initFetchController];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

- (void)configureCell:(BSLineCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self getLine:indexPath];
    
    cell.textFieldForEdit.delegate = self;
    
    if ([self.currentEditingItemId isEqual:[object objectID]] && self.currentEditingItemId != nil)
    {
        // selected cell
        cell.textFieldForEdit.hidden = NO;
        cell.textLabel.hidden = YES;
        cell.textFieldForEdit.text = [[object valueForKey:@"text"] description];
        
        // border of text edit
        [cell.textFieldForEdit.layer setBorderColor:(__bridge CGColorRef)([UIColor colorWithRed:239/255 green:190/255 blue:105/255 alpha:1.0])];
        [cell.textFieldForEdit.layer setBorderWidth:10.0];
    }
    else
    {
        // not selected cell
        cell.textFieldForEdit.hidden = YES;
        cell.textLabel.hidden = NO;
        //cell.textLabel.text = [[[object valueForKey:@"text"] description] stringByAppendingString:[[object valueForKey:@"indent"] description]];
        cell.textLabel.text = [NSString stringWithFormat:@"%@, o:%@, i:%@, p:%@",[[object valueForKey:@"text"] description], [object valueForKey:@"order"], [object valueForKey:@"indent"],[object valueForKey:@"parentProject"]];
        //cell.textLabel.text = [NSString stringWithFormat:@"%@",[[object valueForKey:@"text"] description]];
        
    }
    
    // configure indent view
    int indent = [[object valueForKey:@"indent"] integerValue];
    
    // enumerate over all constraints
    for (NSLayoutConstraint *constraint in cell.checkButton.constraints) {
        // find constraint on this view and with 'width' attribute
        if ((constraint.firstItem == cell.checkButton) &&
            (constraint.firstAttribute == NSLayoutAttributeWidth) &&
            (constraint.secondItem == nil)){
            // increase width of constraint
            constraint.constant = indent * indentPixelValue + 40;
            break;
        }
    }
    
    // add tag to identify clicks
    cell.leftButton.tag = ((indexPath.section & 0xFFFF) << 16) | (indexPath.row & 0xFFFF);
    cell.checkButton.tag = ((indexPath.section & 0xFFFF) << 16) | (indexPath.row & 0xFFFF);
    // same - for projects
    cell.leftButtonProjects.tag = ((indexPath.section & 0xFFFF) << 16) | (indexPath.row & 0xFFFF);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BSLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     if (editingStyle == UITableViewCellEditingStyleDelete) {
     NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
     [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
     
     NSError *error = nil;
     if (![context save:&error]) {
     // Replace this implementation with code to handle the error appropriately.
     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
     NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
     abort();
     }
     }
     */
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    //differ between your sections or if you
    //have only on section return a static value
    return footerHeight;
}

- (void)rememberClickedRow:(UIButton *)sender {
    NSUInteger section = ((sender.tag >> 16) & 0xFFFF);
    NSUInteger row     = (sender.tag & 0xFFFF);
    self.popupIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
    self.popupLine = [self getLine:self.popupIndexPath];
}

- (IBAction)showPopup:(UIButton*)sender forEvent:(UIEvent *)event{
    if (!([sender isKindOfClass:[UIButton class]]))
        return;
    
    // remember current line
    [self rememberClickedRow:sender];
    
    // show radial menu
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:[self popupNibName] owner:self options:nil];
    self.popupView = [nibContents objectAtIndex:0];
    [self.tableView addSubview:self.popupView];
    
    // set position for radial menu
    CGRect popupViewRect = self.popupView.frame;
    
    // get coordinates of touch inside the row
    NSSet *touches;
    touches = [event touchesForView:sender];
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self.tableView];
    
    int width = popupViewRect.size.width;
    int height = popupViewRect.size.height;
    
    // do not go too far to sides
    int popupHalfWidth = 190 / 2;//265 / 2;
    int popupHalfHeight = 190 / 2;//265 / 2;
    int x = touchLocation.x - width / 2;
    int y = touchLocation.y - height / 2;
    
    if (touchLocation.x < popupHalfWidth)
        x = popupHalfWidth - width / 2;;
    
    if (touchLocation.y < popupHalfHeight)
        y = popupHalfHeight - height / 2;
    
    if ( (self.tableView.frame.size.width - touchLocation.x) < popupHalfWidth)
        x = (self.tableView.frame.size.width - popupHalfWidth) - width / 2;
    
    if ( (self.tableView.frame.size.height - touchLocation.y + self.tableView.contentOffset.y) < popupHalfHeight)
        y = (self.tableView.frame.size.height - popupHalfHeight + self.tableView.contentOffset.y) - height / 2;
    
    // compensate for row height
    //y += rowHeightPixelValue / 2;
    
    self.popupView.frame = CGRectMake(x, y, width, height);
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField.tag == 101) {
        [theTextField resignFirstResponder];
        
        // save changes to DB
        NSManagedObjectID *editedId = self.currentEditingItemId;
        
        if (editedId != nil){
            [self.dataController saveLine:editedId withText:theTextField.text];
        }
        self.currentEditingItemId = nil;
        
        [self.tableView reloadData];
    } else if (theTextField == self.theNewLineTextField){
        if ([self.theNewLineTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0){
            // insert new task if it's not empty
            [self newTaskButtonClicked:nil];
        } else {
            // stop entering new tasks
            [theTextField resignFirstResponder];
        }
        
    }
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSError *error = nil;
    //[self.fetchResultsController performFetch:&error];
    
    //id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchResultsController sections][section];
    //int count2 = [sectionInfo numberOfObjects];
    int count = [self.fetchResultsController.fetchedObjects count];
    return count;
}

- (IBAction)newTaskButtonClicked:(id)sender {
    // check for empty line
    if (self.theNewLineTextField.text.length > 0)
    {
        Line *line = [self.dataController createNewLineForSaving];
        line.text = self.theNewLineTextField.text;
        line.order = 0; // take last order
        line.parentProject = [self getAParentProject];
        line.type = [self getLineType];
        
        [self.tableView beginUpdates];
        
        //int newLineOrder =
        [self.dataController saveLine:line];
        
        // clear new task
        self.theNewLineTextField.text = @"";
        
        // animate the insert
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.fetchResultsController.fetchedObjects count]-1 inSection:0];
        NSArray *newLineArray = [[NSArray alloc] initWithObjects:indexPath, nil];
        [self.tableView insertRowsAtIndexPaths:newLineArray withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView endUpdates];
        
        // scroll to new line
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    } else {
        // entry is empty
        [self.theNewLineTextField resignFirstResponder];
        
    }
}

@end
