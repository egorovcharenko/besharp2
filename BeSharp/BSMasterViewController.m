//
//  BSMasterViewController.m
//  BeSharp
//
//  Created by Egor Ovcharenko on 28.12.12.
//  Copyright (c) 2012 Egor Ovcharenko. All rights reserved.
//

#import "BSMasterViewController.h"

#import "BSDataController.h"
#import "BSProjectsViewController.h"

#import "Line.h"
#import "BSLineCell.h"
#import "BSSidePanelViewController.h"

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
    
    // update all rows after deleted!!
    [self.tableView reloadData];
    [self.tableView endUpdates];
}

-(NSInteger) leftShift
{
    return 0;
}

- (IBAction)leftButtonClicked:(id)sender {
    [self showPopup:sender];
}

- (IBAction)pomodoroButtonClicked:(id)sender {
    // hide popup
    [popupView removeFromSuperview];
    
    // set task as focused on the left panel
    BSSidePanelViewController *sidePanelController = (BSSidePanelViewController*) self.viewDeckController.leftController;
    sidePanelController.focusedTask = self.popupLine;
    
    // show left panel
    [self.viewDeckController openLeftView];
}

- (IBAction)popupBackgroundButtonClicked:(id)sender {
    // hide popup
    [popupView removeFromSuperview];
}

- (IBAction)markAsGoalClicked:(id)sender {
    // set as last goal
    self.popupLine.goalType = 1;
    self.popupLine.goalOrder = [self.dataController lastGoalOrderByType:1] + 1;
    
    // save line
    [self.dataController saveLine:self.popupLine];
    
    // update left goals table
    [((BSSidePanelViewController*)self.viewDeckController.leftController).goalsTable reloadData];
    
    // hide popup
    [popupView removeFromSuperview];
}

- (IBAction)moveToProjectClicked:(id)sender
{
    // hide popup
    [popupView removeFromSuperview];
    
    // set delegate
    BSProjectsViewController *projectsViewController = (BSProjectsViewController*) self.viewDeckController.rightController;
    projectsViewController.lineSelectedDelegate = self;
    
    // remember line
    self.lineWithProbablyNewProject = self.popupLine;
    
    // set selection mode for project screen
    projectsViewController.selectionMode = YES;
    
    // show projects view
    [self.viewDeckController openRightView];
}

// called when project is selected for line
-(void) selectedLine:(Line*)selectedProjectForLine
{
    BSProjectsViewController *projectsViewController = (BSProjectsViewController*) self.viewDeckController.rightController;
    
    // reset selection mode for project screen
    projectsViewController.selectionMode = NO;
    
    // close projects view
    [self.viewDeckController closeRightView];

    // set new project
    if (selectedProjectForLine != nil){
        [self.tableView beginUpdates];
        self.lineWithProbablyNewProject.parentProject = selectedProjectForLine;
        
        // save line
        [self.dataController saveLine:self.lineWithProbablyNewProject];
    
        // update row
        NSArray *indexArray = [NSArray arrayWithObject:self.popupIndexPath];
        [self.tableView deleteRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView endUpdates];
    }
}

- (NSString*) popupNibName
{
    return @"LinePopupView";
}

- (Line*) getAParentProject
{
    return self.parentProject;
}

-(Line*) parentProject
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
    
    // refresh all lines
    [self.tableView reloadData];
    
    // refresh header
    self.headerManualView = nil;
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
