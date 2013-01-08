//
//  BSMasterViewController.m
//  BeSharp
//
//  Created by Egor Ovcharenko on 28.12.12.
//  Copyright (c) 2012 Egor Ovcharenko. All rights reserved.
//

#import "BSMasterViewController.h"

#import "BSDataController.h"

#import "BSLine.h"
#import "BSLineCell.h"


@interface BSMasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation BSMasterViewController

@synthesize popupView;

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
    
    // inlnine editing
    //self.txtField=[[UITextField alloc]initWithFrame:CGRectMake(5, 5, 310, 35)];
    //self.txtField.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //self.txtField.autoresizesSubviews=YES;
    //self.txtField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //[self.txtField setBorderStyle:UITextBorderStyleRoundedRect];
    //[self.txtField setPlaceholder:@"Type Data Here"];
    //self.txtField.returnKeyType = UIReturnKeyDone;
    //self.txtField.delegate = self;
    
    //Create an negatively sized or offscreen textfield
    //UITextField *hiddenField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, -10, -10)];
    //hiddenTextField = hiddenField;
    //[self.view addSubview:hiddenTextField];
    //[hiddenField release];
    
    //Set the hiddenTextField to become first responder
    //[hiddenTextField becomeFirstResponder];
    
    // top entry of new task button
    self.textBoxNewTask.delegate = self;
    
    // nothing is being edited
    self.currentEditingItemId = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    BSLine *line = [BSLine alloc];
    
    line.text = self.textBoxNewTask.text;
    line.order = 0; // take last order
    
    int newLineOrder = [self.dataController addNewLineWithLine:line];
    
    // clear new task
    self.textBoxNewTask.text = @"";
    
    // scroll to new line
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newLineOrder - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self.dataController getAllLines] sections] count];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
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

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //NSManagedObject *object = [[self.dataController getAllLines] objectAtIndexPath:indexPath];
        //[[segue destinationViewController] setDetailItem:object];
    }
}

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
//    UITableView *tableView = self.tableView;
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            break;
//            
//        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
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
        cell.textLabel.text = [[[object valueForKey:@"text"] description] stringByAppendingString:[[object valueForKey:@"indent"] description]];
    }
    
    // configure indent view
    int indent = [[object valueForKey:@"indent"] integerValue];
    CGRect frm = cell.indentView.frame;
    frm.size.width = indent * 20;
    cell.indentView.frame = frm;
    
    // add tag to identify clicks
    cell.leftButton.tag = ((indexPath.section & 0xFFFF) << 16) | (indexPath.row & 0xFFFF);
    
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
        //[self.txtField removeFromSuperview];
        
        [self.tableView reloadData];
    } else if (theTextField == self.textBoxNewTask){
        if ([self.textBoxNewTask.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0){
            
            // insert new task if it's not empty
            [self insertNewObject:nil];
        } else {
            // stop entering new tasks
            [theTextField resignFirstResponder];
        }
        
    }
    return YES;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // save changes to DB
    NSManagedObjectID *editedId = self.currentEditingItemId;
    
    if (editedId != nil){
        [self.dataController saveLine:editedId withText:self.currentlySelectedCell.textFieldForEdit.text];
        
        //BSLine *prevEditedLine = [self.dataController getLine:self.currentEditingItemId];
        
        self.currentlySelectedCell.textFieldForEdit.hidden = YES;
        self.currentlySelectedCell.textLabel.hidden = NO;
        self.currentlySelectedCell.textLabel.text = self.currentlySelectedCell.textFieldForEdit.text;
        
        //[self.tableView reloadData];
    }
    
    return indexPath;
}

- (IBAction)leftButtonOnCellClicked:(UIButton*)sender forEvent:(UIEvent *)event {
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"LinePopupView"
                                                         owner:self
                                                       options:nil];
    // remember current line
    if (!([sender isKindOfClass:[UIButton class]]))
        return;
    NSUInteger section = ((sender.tag >> 16) & 0xFFFF);
    NSUInteger row     = (sender.tag & 0xFFFF);
    self.popupIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
    self.popupLine = [[self.dataController getAllLines] objectAtIndexPath:indexPath];
    
    // show radial menu
    self.popupView = [nibContents objectAtIndex:0];
    [self.tableView addSubview:self.popupView];
}

- (IBAction)indentMinusAction:(id)sender {

    [popupView removeFromSuperview];
}

- (IBAction)indentPlusAction:(id)sender {
    // increase indent
    if (self.popupLine != nil){
        [self.dataController increaseIndent:[self.popupLine objectID]];
    }
    
    // hide popup
    [popupView removeFromSuperview];
    
    // update row
    [self.tableView reloadRowsAtIndexPath:self.popupIndexPath withRowAnimation:<#(UITableViewRowAnimation)#>]
}
@end
