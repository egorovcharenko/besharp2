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
    //[self.tableView reloadData];
    [self reloadLeftAndCenterPanes];
}

-(NSInteger) leftShift
{
    return 0;
}

- (IBAction)leftButtonClicked:(id)sender forEvent:(UIEvent *)event{
    [self showPopup:sender forEvent:event];
}



- (IBAction)addNewTaskAbove:(id)sender {
    // first normalize
    [self.dataController normalizeOrder:[self getAParentProject]];
    
    int increment = 0;
    int indentIncrement = 0;
    
    [self addLineInternalWithIncrement:increment indentIncrement:indentIncrement];
    
    // hide popup
    [popupView removeFromSuperview];
}

- (IBAction)addNewTaskBelow:(id)sender {
    // first normalize
    [self.dataController normalizeOrder:[self getAParentProject]];
    
    // find increment for next task
    int increment = [self.dataController findNumberOfChildren:self.popupLine parentProject:[self getAParentProject]] + 1;
    int indentIncrement = 0;
    
    [self addLineInternalWithIncrement:increment indentIncrement:indentIncrement];
    
    // hide popup
    [popupView removeFromSuperview];
}

- (IBAction)addNewTaskChild:(id)sender {
    int increment = 1;
    int indentIncrement = 1;
    
    [self addLineInternalWithIncrement:increment indentIncrement:indentIncrement];
    
    // hide popup
    [popupView removeFromSuperview];
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
    if (self.popupLine.goalType == 0){
        // set as last goal
        self.popupLine.goalType = 1;
        self.popupLine.goalOrder = [self.dataController lastGoalOrderByType:1] + 1;
    } else {
        self.popupLine.goalType = 0;
        self.popupLine.goalOrder = 0; // just to pretty
    }
    
    // save line
    [self.dataController saveLine:self.popupLine];
    
    // update left goals table
    [self reloadLeftAndCenterPanes];
    
    //[((BSSidePanelViewController*)self.viewDeckController.leftController).goalsTable reloadData];
    
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
        
        
        
        // run some code after smooth update
        [CATransaction begin];
        
        [CATransaction setCompletionBlock:^{
            // animation has finished - reload all data
            //[self.tableView reloadData];
            [self reloadLeftAndCenterPanes];
            
        }];
        
        [self.tableView beginUpdates];
        self.lineWithProbablyNewProject.parentProject = selectedProjectForLine;
        
        // save line
        [self.dataController saveLine:self.lineWithProbablyNewProject];
        
        // update row
        NSArray *indexArray = [NSArray arrayWithObject:self.popupIndexPath];
        [self.tableView deleteRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView endUpdates];
        
        [CATransaction commit];
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
    //[self.tableView reloadData];
    [self reloadLeftAndCenterPanes];
    
    // refresh header
    self.headerManualView = nil;
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
    //if(self.headerManualView == nil)
    {
        //allocate the view if it doesn't exist yet
        headerManualView  = [[UIView alloc] init];
        
        // get parent project
        Line *curParentProject = [self getAParentProject];
        if (curParentProject != nil){
            int height = headerHeight;
            CGFloat width = CGRectGetWidth(self.view.bounds);
            
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
            
            // "Hide all checked" button
            int numberOfCheckedLines = [self.dataController numberOfCheckedLines:self.parentProject];
            if (numberOfCheckedLines > 0)
            {
                UIButton *hideButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [hideButton setFrame:CGRectMake(5, 7, 78, 30)];
                [hideButton setBackgroundImage:[UIImage imageNamed:@"hide_checked_button.png"] forState:UIControlStateNormal];
                [hideButton setTitle:@"      Delete" forState:UIControlStateNormal];
                [hideButton addTarget:self action:@selector(hideButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [hideButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
                [headerManualView addSubview:hideButton];
            }
            
            // "Inbox" button
            if (self.parentProject.objectID != [self.dataController getInbox].objectID){
                UIButton *inboxButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [inboxButton setFrame:CGRectMake(width - 78 - 10, 7, 78, 30)];
                [inboxButton setBackgroundImage:[UIImage imageNamed:@"inbox_button_2.png"] forState:UIControlStateNormal];
                [inboxButton setTitle:@"" forState:UIControlStateNormal];
                [inboxButton addTarget:self action:@selector(inboxButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                //[inboxButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
                [headerManualView addSubview:inboxButton];
                
            }
            
            // top label
            int x, y, labelW, labelH;
            if (numberOfCheckedLines > 0)
                x = 5 + 78 + 10;
            else
                x = 10;
            
            if (self.parentProject.objectID != [self.dataController getInbox].objectID)
                labelW = width - x - 78 - 10 - 10;
            else {
                // it's inbox
                x = 10;
                labelW = width - x - 10;
            }
            y = 0;
            labelH = height;
            
            UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, labelW, labelH)];
            [topLabel setText:curParentProject.text];
            [topLabel setTextAlignment:NSTextAlignmentCenter];
            [topLabel setBackgroundColor: [UIColor clearColor]];
            [topLabel setTextColor:[UIColor whiteColor]];
            [topLabel setFont:[UIFont fontWithName:@"Helvetica" size:24]];
            [headerManualView addSubview:topLabel];
        }
    }
    
    //return the view for the footer
    return headerManualView;
}

-(void) hideButtonClicked:(id)sender
{
    
    // run some code after smooth update
    [CATransaction begin];
    
    [CATransaction setCompletionBlock:^{
        // animation has finished - reload all data
        //[self.tableView reloadData];
        [self reloadLeftAndCenterPanes];
        
    }];
    
    [self.tableView beginUpdates];
    
    // hide all completed lines
    NSArray *indexArray = [self.dataController hideAllCompletedLinesFromProject:[self getAParentProject]];
    [self.tableView deleteRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView endUpdates];
    
    [CATransaction commit];
    
    // refresh also left panel as some goals could be hidden already
    //BSSidePanelViewController *sidePanelController = (BSSidePanelViewController*) self.viewDeckController.leftController;
    //[sidePanelController.goalsTable reloadData];
}

-(void) inboxButtonClicked:(id)sender
{
    // set inbox
    self.parentProject = [self.dataController getInbox];
    
    // refresh tasks list
    //[self.tableView reloadData];
    [self reloadLeftAndCenterPanes];
    
    
    // refresh also projects list
    BSProjectsViewController *sidePanelController = (BSProjectsViewController*) self.viewDeckController.rightController;
    [sidePanelController.tableView reloadData];
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

- (NSInteger) getLabelWidth
{
    return 245;
}

@end
