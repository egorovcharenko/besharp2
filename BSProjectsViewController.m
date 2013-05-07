//
//  BSMasterViewController.m
//  BeSharp
//
//  Created by Egor Ovcharenko on 28.12.12.
//  Copyright (c) 2012 Egor Ovcharenko. All rights reserved.
//

#import "BSProjectsViewController.h"

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
    [self.tableView reloadData];
}

- (IBAction)popupBackgroundClicked:(id)sender {
    // hide popup
    [popupView removeFromSuperview];
}
@end
