//
//  BSMasterViewController.m
//  BeSharp
//
//  Created by Egor Ovcharenko on 28.12.12.
//  Copyright (c) 2012 Egor Ovcharenko. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>

#import "BSProjectsViewController.h"
#import "BSSidePanelViewController.h"

#import "BSDataController.h"

#import "Line.h"
#import "BSLineCell.h"

#import "consts.h"

#import "IIViewDeckController.h"
#import "BSMasterViewController.h"



@interface BSProjectsViewController ()
@end

@implementation BSProjectsViewController

@synthesize popupView;
@synthesize headerView;
@synthesize headerManualView;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"projects_background.png"]];
    
    // set color of separators
    self.tableView.separatorColor = [UIColor blackColor];
    
    // set default prompt
    self.theNewLineTextField.placeholder = @"Type new project here ...";
    
    self.selectionMode = NO;
}

- (NSInteger) getLineType
{
    return 2;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(NSInteger) leftShift
{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Line *line = [self getLine:indexPath];
    
    if (self.selectionMode){
        if (self.lineSelectedDelegate != nil){
            [self.lineSelectedDelegate selectedLine:line];
        }
    } else {
        // set this project as root
        BSMasterViewController *masterViewController = (BSMasterViewController*) self.viewDeckController.centerController;
        masterViewController.parentProject = line;
        
        // show center
        [self.viewDeckController closeRightView];
        
        // refresh the view so selected project will be orange
        [self.tableView reloadData];
    }
}

- (NSString*) popupNibName
{
    return @"ProjectPopupView";
}

- (IBAction)leftButtonClickedWithEvent:(id)sender forEvent:(UIEvent *)event {
    [self showPopup:sender  forEvent:event];
}

- (Line*) getAParentProject
{
    return nil;
}

- (Line*) getLine:(NSIndexPath *)indexPath
{
    return [self.fetchResultsController objectAtIndexPath:indexPath];
}

- (IBAction)completeProjectWasClicked:(id)sender forEvent:(UIEvent *)event {
    // remember clicked line
    [self rememberClickedRow:sender];
    
    // actually complete the project
    //[self.tableView beginUpdates];
    
    // complete the project
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
    //[popupView removeFromSuperview];
    
    // update row
    //NSArray *indexArray = [NSArray arrayWithObject:self.popupIndexPath];
    
    //[self.tableView deleteRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
    
    // update all rows after deleted!!
    //[self.tableView reloadData];
    //[self.tableView endUpdates];
    
    // reload data so tags will be updated
    //[self.tableView reloadData];
    [self reloadLeftAndCenterPanes];
}

- (IBAction)popupBackgroundClicked:(id)sender {
    // hide popup
    [popupView removeFromSuperview];
}

- (IBAction)decreaseProjectIndent:(id)sender {
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

- (IBAction)increaseIndent:(id)sender {
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

- (void)startInlineEditing:(NSIndexPath *)indexPath
{
    Line *line = [self getLine:indexPath];
    
    // inline editing
    self.currentEditingItemId = [line objectID];
    self.currentlySelectedCell = (BSLineCell*) [self.tableView cellForRowAtIndexPath:indexPath];
    
    self.currentlySelectedCell.textFieldForEdit.hidden = NO;
    self.currentlySelectedCell.textLabel.hidden = YES;
    self.currentlySelectedCell.textFieldForEdit.text = line.text;
    self.currentlySelectedCell.textFieldForEdit.textColor = [UIColor blackColor];
    
    [self.currentlySelectedCell.textFieldForEdit becomeFirstResponder];
    
    // hide popup
    [popupView removeFromSuperview];
}

- (IBAction)editProjectClicked:(id)sender
{
    [self startInlineEditing:self.popupIndexPath];
}

- (IBAction)setAsLifeGoalClicked:(id)sender
{
    if (self.popupLine.goalType == 0){
        // set as last goal
        self.popupLine.goalType = 3;
        self.popupLine.goalOrder = [self.dataController lastGoalOrderByType:1] + 1;
    } else {
        self.popupLine.goalType = 0;
        self.popupLine.goalOrder = 0;
    }
    // save line
    [self.dataController saveLine:self.popupLine];
    
    // update left goals table
    [self reloadLeftAndCenterPanes];
    
    // hide popup
    [popupView removeFromSuperview];
}

- (IBAction)setAsWeeklyGoalClicked:(id)sender {
    if (self.popupLine.goalType == 0){
        // set as last goal
        self.popupLine.goalType = 2;
        self.popupLine.goalOrder = [self.dataController lastGoalOrderByType:1] + 1;
    } else {
        self.popupLine.goalType = 0;
        self.popupLine.goalOrder = 0;
    }
    
    // save line
    [self.dataController saveLine:self.popupLine];
    
    // update left goals table
    [self reloadLeftAndCenterPanes];
    
    // hide popup
    [popupView removeFromSuperview];
}

- (IBAction)addNewProjectAboveClicked:(id)sender
{
    // first normalize
    [self.dataController normalizeOrder:[self getAParentProject]];
    
    int increment = 0;
    int indentIncrement = 0;
    
    [self addLineInternalWithIncrement:increment indentIncrement:indentIncrement];
    
    // hide popup
    [popupView removeFromSuperview];
}

- (IBAction)addNewProjectBelowClicked:(id)sender
{
    // first normalize
    [self.dataController normalizeOrder:[self getAParentProject]];
    
    // find increment for next task
    int increment = 1;
    int indentIncrement = 0;
    
    [self addLineInternalWithIncrement:increment indentIncrement:indentIncrement];
    
    // hide popup
    [popupView removeFromSuperview];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //differ between your sections or if you
    //have only on section return a static value
    int numberOfCheckedProjects = [self.dataController numberOfCheckedProjects];
    if (numberOfCheckedProjects > 0)
    {
        return 43;
    } else {
        return 43;
        // TODO return 0 here
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //if(self.headerManualView == nil)
    {
        //allocate the view if it doesn't exist yet
        headerManualView  = [[UIView alloc] init];
        
        int height = headerHeight;
        CGFloat width = CGRectGetWidth(self.view.bounds);
        
        // Stretch top
        UIView* top_back = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        [top_back setBackgroundColor:[UIColor blackColor]];
        // add to view
        [headerManualView addSubview:top_back];

        // "Hide all checked" button
        int numberOfCheckedProjects = [self.dataController numberOfCheckedProjects];
        if (numberOfCheckedProjects > 0)
        {
            UIButton *hideButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [hideButton setFrame:CGRectMake([self leftShift] + 5, 7, 78, 30)];
            [hideButton setBackgroundImage:[UIImage imageNamed:@"hide_checked_button.png"] forState:UIControlStateNormal];
            [hideButton setTitle:@"      Delete" forState:UIControlStateNormal];
            [hideButton addTarget:self action:@selector(hideButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [hideButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [headerManualView addSubview:hideButton];
        }
        
        // top label
        int x, y, labelW, labelH;
        x = 10 + [self leftShift];
        labelW = + width - x - 10;
        y = 0;
        labelH = height;
        
        UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, labelW, labelH)];
        [topLabel setText:@"Projects"];
        [topLabel setTextAlignment:NSTextAlignmentCenter];
        [topLabel setBackgroundColor: [UIColor clearColor]];
        [topLabel setTextColor:[UIColor whiteColor]];
        [topLabel setFont:[UIFont fontWithName:@"Helvetica" size:24]];
        [headerManualView addSubview:topLabel];
    }
    
    //return the view for the header
    return headerManualView;
}

-(void) hideButtonClicked:(id)sender
{
    // find focused task
    BSSidePanelViewController *sidePanelController = (BSSidePanelViewController*) self.viewDeckController.leftController;
    Line* focusedTask = sidePanelController.focusedTask;
    
    // pre-show all lines that will be hidden
    NSArray *toBeHiddenArray = [self.dataController hideAllCompletedProjects:NO];
    // hide focused task from the pomodoro
    for (NSIndexPath* ip in toBeHiddenArray) {
        Line* hiddenLine = [self getLine:ip];
        
        //NSLog(@"%@  /  %@", hiddenLine.objectID, focusedTask.objectID);
        
        if (hiddenLine.objectID == focusedTask.objectID){
            sidePanelController.focusedTask = nil;
            break;
        }
    }

    
    // run some code after smooth update
    [CATransaction begin];
    
    [CATransaction setCompletionBlock:^{
        // animation has finished - reload all data
        //[self.tableView reloadData];
        [self reloadLeftAndCenterPanes];
    }];
    
    [self.tableView beginUpdates];
    
    // hide all completed lines
    NSArray *indexArray = [self.dataController hideAllCompletedProjects:YES];
    [self.tableView deleteRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView endUpdates];
    
    [CATransaction commit];
    
    // refresh also left panel as some goals could be hidden already
    //BSMasterViewController *centerController = (BSMasterViewController*) self.viewDeckController.centerController;
    // TODO if removed selected project, show Inbox on central screen instead
    //if (centerController.parentProject)
    //[sidePanelController.goalsTable reloadData];
}

- (NSInteger) getLabelWidth
{
    return 203;
}

@end
