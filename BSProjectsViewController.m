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
    return 50;
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
    return @"BSProjectPopup";
}

- (IBAction)leftButtonClicked:(id)sender {
    [self showPopup:sender];
}

- (Line*) getAParentProject
{
    return nil;
}

- (Line*) getLine:(NSIndexPath *)indexPath
{
    return [self.fetchResultsController objectAtIndexPath:indexPath];
}
@end
