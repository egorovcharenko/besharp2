//
//  BSMasterViewController.m
//  BeSharp
//
//  Created by Egor Ovcharenko on 28.12.12.
//  Copyright (c) 2012 Egor Ovcharenko. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

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
@synthesize headerManualView;

- (void)viewDidLoad
{
    [self setDataController];
    self.parentProject = [self.dataController getInbox];
    
    // set background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
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
    //[self.tableView beginUpdates];
    
    // complete the task
    if (self.popupLine != nil){
        if (self.popupLine.isCompleted){
            self.popupLine.isCompleted = NO;
        } else {
            self.popupLine.isCompleted = YES;
        }
    }
    
    // save updated line
    [self.dataController saveLine:self.popupLine];
    
    // hide popup
    [popupView removeFromSuperview];
    
    // update row
    //NSArray *indexArray = [NSArray arrayWithObject:self.popupIndexPath];
    
    //[self.tableView deleteRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
    
    //[self.tableView endUpdates];
    
    // update all rows after deleted!!
    [self.tableView reloadData];
}

-(NSInteger) leftShift
{
    return 0;
}

- (IBAction)leftButtonClicked:(id)sender forEvent:(UIEvent *)event{
    [self showPopup:sender forEvent:event];
}


- (void)addLineInternalWithIncrement:(int)increment indentIncrement:(int)indentIncrement {
    // Calc order for the new line
    int newOrder = self.popupLine.order + increment;
    
    // Change order for all other lines
    [self.dataController addOrderToAllLinesStartingOrder:newOrder fromProject:self.popupLine.parentProject];
    
    // Add Line itself
    Line *line = [self.dataController createNewLineForSaving];
    line.text = @"";
    line.order = newOrder;
    line.parentProject = [self getAParentProject];
    line.type = [self getLineType];
    line.indent = self.popupLine.indent + indentIncrement;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.popupIndexPath.row + increment) inSection:self.popupIndexPath.section];
    
    // run some code after smooth update
    [CATransaction begin];
    
    [CATransaction setCompletionBlock:^{
        // animation has finished - reload all data
        [self.tableView reloadData];
        // start editing new line
        [self startInlineEditing:indexPath];
    }];
    
    [self.tableView beginUpdates];
    
    [self.dataController saveLine:line];
    NSArray *newLineArray = [[NSArray alloc] initWithObjects:indexPath, nil];
    [self.tableView insertRowsAtIndexPaths:newLineArray withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.tableView endUpdates];
    
    [CATransaction commit];
    
    // scroll to new line
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    
    // hide popup
    [popupView removeFromSuperview];
}

- (IBAction)addNewTaskAbove:(id)sender {
    int increment = 0;
    int indentIncrement = 0;
    
    [self addLineInternalWithIncrement:increment indentIncrement:indentIncrement];

}

- (IBAction)addNewTaskBelow:(id)sender {
    int increment = 1;
    int indentIncrement = 0;
    
    [self addLineInternalWithIncrement:increment indentIncrement:indentIncrement];
}

- (IBAction)addNewTaskChild:(id)sender {
    int increment = 1;
    int indentIncrement = 1;
    
    [self addLineInternalWithIncrement:increment indentIncrement:indentIncrement];

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

- (void)startInlineEditing:(NSIndexPath *)indexPath
{
    Line *line = [self getLine:indexPath];
    
    // inline editing
    self.currentEditingItemId = [line objectID];
    self.currentlySelectedCell = (BSLineCell*) [self.tableView cellForRowAtIndexPath:indexPath];
    
    self.currentlySelectedCell.textFieldForEdit.hidden = NO;
    self.currentlySelectedCell.textLabel.hidden = YES;
    self.currentlySelectedCell.textFieldForEdit.text = line.text;
    
    [self.currentlySelectedCell.textFieldForEdit becomeFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self startInlineEditing:indexPath];
}

- (Line*) getLine:(NSIndexPath *)indexPath
{
    return [self.fetchResultsController objectAtIndexPath:indexPath];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(self.headerManualView == nil) {
        //allocate the view if it doesn't exist yet
        headerManualView  = [[UIView alloc] init];
        
        // get parent project
        Line *curParentProject = [self getAParentProject];
        if (curParentProject != nil){
            int height = headerHeight;
            
            // top label
            CGFloat width = CGRectGetWidth(self.view.bounds);
            UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
            [topLabel setText:curParentProject.text];
            [topLabel setTextAlignment:NSTextAlignmentCenter];
            [topLabel setBackgroundColor: [UIColor clearColor]];
            [topLabel setTextColor:[UIColor whiteColor]];
            [topLabel setFont:[UIFont fontWithName:@"Helvetica" size:24]];
            
            // Stretch top
            UIEdgeInsets edge = UIEdgeInsetsMake(0, 3, 0, 3);
            UIImage *tasks_top = [UIImage imageNamed:@"tasks_top.png"];
            UIImage *stretchableImage = [tasks_top resizableImageWithCapInsets:edge];
            
            UIImageView* top_back = [[UIImageView alloc] initWithImage:stretchableImage];
            top_back.contentMode = UIViewContentModeScaleToFill;
            top_back.frame = CGRectMake(
                                top_back.frame.origin.x,
                                top_back.frame.origin.y, width, height);
            
            // add to view
            [headerManualView addSubview:top_back];
            [headerManualView addSubview:topLabel];
        }
    }
    
    //return the view for the footer
    return headerManualView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //differ between your sections or if you
    //have only on section return a static value
    return headerHeight;
}

- (IBAction)markAsCompleted:(id)sender {
    // remember clicked line
    [self rememberClickedRow:sender];
    
    // actually complete the task
    [self completeTaskClicked:sender];
    
    // reload data so tags will be updated
    //[self.tableView reloadData];
}
@end
