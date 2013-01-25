//
//  BSDataController.h
//  BeSharp
//
//  Created by Egor Ovcharenko on 28.12.12.
//  Copyright (c) 2012 Egor Ovcharenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BSAppDelegate;
@class Line;

@interface BSDataController : NSObject <NSFetchedResultsControllerDelegate>

@property NSManagedObjectContext *context;
//@property NSFetchedResultsController *fetchedResultsController;
@property NSObject <NSFetchedResultsControllerDelegate> *fetchedResultsControllerDelegate;

- (BSDataController*) initWithAppDelegate:(BSAppDelegate *)delegate fetchedControllerDelegate:(NSObject <NSFetchedResultsControllerDelegate>*)fetchedResultsControllerDelegate;

// add lines
- (int) saveLine:(Line *) newLine;
- (Line*) createNewLineForSaving;

// getting lines
//- (NSFetchedResultsController *) getAllLines;
- (NSFetchedResultsController *) getAllLinesFromProject:(Line*)project;
- (NSFetchedResultsController *) getAllLinesFromProject:(Line*)project lineType:(NSInteger)lineType;
//- (Line*) getManagedLine: (NSManagedObjectID *)lineId;

// updating lines
- (void) saveLine: (NSManagedObjectID *)lineId withText:(NSString *) newText;
- (void) saveLine: (NSManagedObjectID *)lineId withIndent:(NSInteger) newIndent;
- (void) changeIndent: (NSManagedObjectID *)lineId indentChange: (NSInteger) indentChange;
// completion
- (void) setCompletedFlag: (NSManagedObjectID *)lineId isCompleted:(Boolean) isCompleted ;
// set as a project
- (void) setProjectFlag: (NSManagedObjectID *)lineId isProject:(Boolean) isProject ;

// reordering
- (void) moveLineFrom:(NSInteger)startPos to:(NSInteger)newPos;

// get inbox managedId
- (Line*) getInbox;

@end
