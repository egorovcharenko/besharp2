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
- (void) addNewLineWithLine:(BSLine *) newLine;
- (NSFetchedResultsController *) getAllLines;

@end
