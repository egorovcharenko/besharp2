//
//  BSMasterViewController.m
//  BeSharp
//
//  Created by Egor Ovcharenko on 28.12.12.
//  Copyright (c) 2012 Egor Ovcharenko. All rights reserved.
//

#import "BSMasterViewController.h"

#import "BSDataController.h"

#import "Line.h"
#import "BSLineCell.h"

#import "consts.h"

#import "IIViewDeckController.h"


@interface BSMasterViewController ()
@end

@implementation BSMasterViewController

@synthesize popupView;
@synthesize headerView;
@synthesize parentProject;

- (void)viewDidLoad
{
    [self setDataController];
    self.parentProject = [self.dataController getInbox];
    [super viewDidLoad];    
}

- (NSInteger) getLineType
{
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (IBAction)indentMinusAction:(id)sender {
    // decrease indent
    if (self.popupLine != nil){
        [self.dataController changeIndent:[self.popupLine objectID] indentChange:-1];
    }
    
    // hide popup
    [popupView removeFromSuperview];
    
    // update row
    NSArray *indexArray = [NSArray arrayWithObject:self.popupIndexPath];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (IBAction)indentPlusAction:(id)sender {
    // increase indent
    if (self.popupLine != nil){
        [self.dataController changeIndent:[self.popupLine objectID] indentChange:1];
    }
    
    // hide popup
    [popupView removeFromSuperview];
    
    // update row
    NSArray *indexArray = [NSArray arrayWithObject:self.popupIndexPath];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (IBAction)completeTaskClicked:(id)sender {
    [self.tableView beginUpdates];
    
    // complete the task
    if (self.popupLine != nil){
        [self.dataController setCompletedFlag:[self.popupLine objectID] isCompleted:YES];
    }
    // hide popup
    [popupView removeFromSuperview];
    
    // update row
    NSArray *indexArray = [NSArray arrayWithObject:self.popupIndexPath];
    
    [self.tableView deleteRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
    //[self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
    
    // update all rows after deleted!!
    [self.tableView reloadData];
    [self.tableView endUpdates];
}

- (IBAction)markAsProjectClicked:(id)sender {
    [self.tableView beginUpdates];
    
    if (self.popupLine != nil){
        if ([[self.popupLine valueForKey:@"isProject"] integerValue] == 0){
            // mark as project
            [self.dataController setProjectFlag:[self.popupLine objectID] isProject:1];
        } else {
            // unmark as project
            [self.dataController setProjectFlag:[self.popupLine objectID] isProject:0];
        }
    }
    // hide popup
    [popupView removeFromSuperview];
    
    // update row
    NSArray *indexArray = [NSArray arrayWithObject:self.popupIndexPath];
    
    [self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (IBAction)leftButtonClicked:(id)sender {
    [self showPopup:sender];
}

- (NSString*) popupNibName
{
    return @"LinePopupView";
}

- (Line*) getAParentProject
{
    // todo
    return self.parentProject;
    //return [self.dataController getInbox];
}

- (Line*) getParentProject
{
    // todo
    return parentProject;
    //return [self.dataController getInbox];
}

-(void) setParentProject:(Line*)aParentProject
{
    parentProject = aParentProject;
    
    // refresh data after parent changed
    [self initFetchController];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Line *line = [self getLine:indexPath];
    
    // inline editing
    self.currentEditingItemId = [line objectID];
    self.currentlySelectedCell = (BSLineCell*) [self.tableView cellForRowAtIndexPath:indexPath];
    
    self.currentlySelectedCell.textFieldForEdit.hidden = NO;
    self.currentlySelectedCell.textLabel.hidden = YES;
    self.currentlySelectedCell.textFieldForEdit.text = line.text;
    
    [self.currentlySelectedCell.textFieldForEdit becomeFirstResponder];
    //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    //[self.tableView reloadData];
}

- (Line*) getLine:(NSIndexPath *)indexPath
{
    return [self.fetchResultsController objectAtIndexPath:indexPath];
}

@end
