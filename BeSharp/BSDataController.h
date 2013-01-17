//
//  BSDataController.h
//  BeSharp
//
//  Created by Egor Ovcharenko on 28.12.12.
//  Copyright (c) 2012 Egor Ovcharenko. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BSAppDelegate;
@class BSLine;

@interface BSDataController : NSObject <NSFetchedResultsControllerDelegate>

@property NSManagedObjectContext *context;
@property NSFetchedResultsController *fetchedResultsController;
@property NSObject <NSFetchedResultsControllerDelegate> *fetchedResultsControllerDelegate;

- (BSDataController*) initWithAppDelegate:(BSAppDelegate *)delegate fetchedControllerDelegate:(NSObject <NSFetchedResultsControllerDelegate>*)fetchedResultsControllerDelegate;
- (int) addNewLineWithLine:(BSLine *) newLine;
- (NSFetchedResultsController *) getAllLines;
- (void) saveLine: (NSManagedObjectID *)lineId withText:(NSString *) newText;
- (void) saveLine: (NSManagedObjectID *)lineId withIndent:(NSInteger) newIndent;

- (void) changeIndent: (NSManagedObjectID *)lineId indentChange: (NSInteger) indentChange;

// get line
- (BSLine*) getLine: (NSManagedObjectID *)lineId;
- (NSManagedObject*) getManagedLine: (NSManagedObjectID *)lineId;

// reordering
- (void) moveLineFrom:(NSInteger) startPos to:(NSInteger) newPos;

// completion
- (void) setCompletedFlag: (NSManagedObjectID *)lineId isCompleted:(Boolean) isCompleted ;

// set as a project
- (void) setProjectFlag: (NSManagedObjectID *)lineId isProject:(Boolean) isProject ;

@end
