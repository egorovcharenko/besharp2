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

#import "consts.h"

#import "IIViewDeckController.h"


@interface BSMasterViewController ()
@end

@implementation BSMasterViewController

@synthesize popupView;
@synthesize headerView;

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



@end
