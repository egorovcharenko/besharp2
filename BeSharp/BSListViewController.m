//
//  BSListViewController.m
//  
//
//  Created by Egor Ovcharenko on 17.01.13.
//
//

#import "BSListViewController.h"

#import "BSDataController.h"

#import "BSLine.h"
#import "BSLineCell.h"

#import "consts.h"

#import "IIViewDeckController.h"

@implementation BSListViewController

@synthesize headerManualView;
//@synthesize newLineTextField;

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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if(self.headerManualView == nil) {
        //allocate the view if it doesn't exist yet
        headerManualView  = [[UIView alloc] init];
        
        self.theNewLineTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 3, 250, 44)];
        self.theNewLineTextField.borderStyle = UITextBorderStyleRoundedRect;
        [headerManualView addSubview:self.theNewLineTextField];
        
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [addButton setFrame:CGRectMake(270, 3, 44, 44)];
        [addButton setTitle:@"+" forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(newTaskButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [headerManualView addSubview:addButton];
    }
    
    //return the view for the footer
    return headerManualView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [[self.dataController getAllLines] objectAtIndexPath:indexPath];
    
    // inline editing
    self.currentEditingItemId = [object objectID];
    self.currentlySelectedCell = (BSLineCell*) [self.tableView cellForRowAtIndexPath:indexPath];
    
    self.currentlySelectedCell.textFieldForEdit.hidden = NO;
    self.currentlySelectedCell.textLabel.hidden = YES;
    self.currentlySelectedCell.textFieldForEdit.text = [[object valueForKey:@"text"] description];
    
    [self.currentlySelectedCell.textFieldForEdit becomeFirstResponder];
    //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    //[self.tableView reloadData];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    // setup buttons on top
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    // misc
    self.detailViewController = (BSDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    // data controller
    self.dataController = [[BSDataController alloc]initWithAppDelegate:(BSAppDelegate*)[[UIApplication sharedApplication] delegate] fetchedControllerDelegate:self];
    
    // top entry of new task button
    self.theNewLineTextField.delegate = self;
    
    // nothing is being edited
    self.currentEditingItemId = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self.dataController getAllLines] sections] count];
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
    NSManagedObject *object = [[self.dataController getAllLines] objectAtIndexPath:indexPath];
    
    cell.textFieldForEdit.delegate = self;
    
    if ([self.currentEditingItemId isEqual:[object objectID]] && self.currentEditingItemId != nil)
    {
        // selected cell
        cell.textFieldForEdit.hidden = NO;
        cell.textLabel.hidden = YES;
        cell.textFieldForEdit.text = [[object valueForKey:@"text"] description];
    }
    else
    {
        // not selected cell
        cell.textFieldForEdit.hidden = YES;
        cell.textLabel.hidden = NO;
        //cell.textLabel.text = [[[object valueForKey:@"text"] description] stringByAppendingString:[[object valueForKey:@"indent"] description]];
        cell.textLabel.text = [NSString stringWithFormat:@"%@, o:%@, i:%@, p:%@",[[object valueForKey:@"text"] description], [object valueForKey:@"order"], [object valueForKey:@"indent"],[object valueForKey:@"isProject"]];
    }
    
    // project
    if ([[object valueForKey:@"isProject"] integerValue] == 1){
        [cell.textLabel setFont:[UIFont boldSystemFontOfSize:20]];
    } else {
        [cell.textLabel setFont:[UIFont boldSystemFontOfSize:16]];
    }
    
    // configure indent view
    int indent = [[object valueForKey:@"indent"] integerValue];

    // enumerate over all constraints
    for (NSLayoutConstraint *constraint in cell.indentView.constraints) {
        // find constraint on this view and with 'width' attribute
        if ((constraint.firstItem == cell.indentView) &&
            (constraint.firstAttribute == NSLayoutAttributeWidth) &&
            (constraint.secondItem == nil)){
            // increase width of constraint
            constraint.constant = indent * indentPixelValue;
            break;
        }
    }

    // add tag to identify clicks
    cell.leftButton.tag = ((indexPath.section & 0xFFFF) << 16) | (indexPath.row & 0xFFFF);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSFetchedResultsController* lines = [self.dataController getAllLines];
    id <NSFetchedResultsSectionInfo> sectionInfo = [lines sections][section];
    return [sectionInfo numberOfObjects];
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

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    //differ between your sections or if you
    //have only on section return a static value
    return 50;
}

- (IBAction)showPopup:(UIButton*)sender {
     // remember current line
    if (!([sender isKindOfClass:[UIButton class]]))
        return;
    NSUInteger section = ((sender.tag >> 16) & 0xFFFF);
    NSUInteger row     = (sender.tag & 0xFFFF);
    self.popupIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
    self.popupLine = [[self.dataController getAllLines] objectAtIndexPath:self.popupIndexPath];
    
    // show radial menu
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:[self popupNibName] owner:self options:nil];
    self.popupView = [nibContents objectAtIndex:0];
    [self.tableView addSubview:self.popupView];
    
    // set position for radial menu
    CGRect popupViewRect = self.popupView.frame;
    CGPoint currentRowPosition = [self.tableView rectForRowAtIndexPath:self.popupIndexPath].origin;
    int indent = [[self.popupLine valueForKey:@"indent"] integerValue];
    
    int x = indent * indentPixelValue;
    int y = currentRowPosition.y;
    int width = popupViewRect.size.width;
    int height = popupViewRect.size.height;
    
    // compensate for row height
    y += rowHeightPixelValue / 2;
    
    // try to center popup on button
    x -= width / 2;
    if (x < 0)
        x = 0;
    
    y -= height / 2;
    if (y < 0)
        y = 0;
    
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

- (IBAction)newTaskButtonClicked:(id)sender {
    BSLine *line = [BSLine alloc];
    
    line.text = self.theNewLineTextField.text;
    line.order = 0; // take last order
    
    [self.tableView beginUpdates];
    
    int newLineOrder = [self.dataController addNewLineWithLine:line];
    
    // clear new task
    self.theNewLineTextField.text = @"";
    
    // scroll to new line
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.dataController.fetchedResultsController.fetchedObjects count]-1 inSection:0];
    
    NSArray *newLineArray = [[NSArray alloc] initWithObjects:indexPath, nil];
    
    [self.tableView insertRowsAtIndexPaths:newLineArray withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    //[self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

@end
