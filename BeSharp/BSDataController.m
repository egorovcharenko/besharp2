//
//  BSDataController.m
//  BeSharp
//
//  Created by Egor Ovcharenko on 28.12.12.
//  Copyright (c) 2012 Egor Ovcharenko. All rights reserved.
//

#import "BSDataController.h"
#import "BSAppDelegate.h"
#import "BSLine.h"

@implementation BSDataController

-(BSDataController*) initWithAppDelegate:(BSAppDelegate *)delegate fetchedControllerDelegate:(NSObject <NSFetchedResultsControllerDelegate>*)fetchedResultsControllerDelegate;
{
    _context = [delegate managedObjectContext];
    _fetchedResultsControllerDelegate = fetchedResultsControllerDelegate;
    return self;
}

-(int) addNewLineWithLine:(BSLine *)newLine
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:self.context];
    NSManagedObject *newManagedLine = [[NSManagedObject alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:self.context];
    
    int result = newLine.order;
    
    [newManagedLine setValue:newLine.text forKey:@"text"];
    
    // if order is not specified - get last one
    if (newLine.order <=0){
        
        // get lines count
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:self.context];
        [fetchRequest setEntity:entity];
        
        // Set the batch size to a suitable number.
        [fetchRequest setFetchBatchSize:20];
        
        NSError *error = nil;
        NSInteger count = -1;
        if (!(count=[self.context countForFetchRequest:fetchRequest error:&error])) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        };
        
        if (count >=0){
            [newManagedLine setValue:[NSNumber numberWithInteger:count] forKey:@"order"];
        }
        result = count;
        
    }
    
    // Save the context.
    NSError *error = nil;
    if (![self.context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return result;
}

-(NSFetchedResultsController*) getAllLines
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    //NSMutableArray *predicateArray = [NSMutableArray array];
    //[predicateArray addObject:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchString]];
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"isCompleted == %@", 0];
    [fetchRequest setPredicate:filterPredicate];

    //[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"isCompleted == %@", 0]];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.fetchedResultsControllerDelegate controllerDidChangeContent:controller];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.fetchedResultsControllerDelegate controllerWillChangeContent:controller];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    [self.fetchedResultsControllerDelegate controller:controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
                                              atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    [self.fetchedResultsControllerDelegate controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
                                          atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
                                         newIndexPath:(NSIndexPath *)newIndexPath];
}

- (void) saveLine: (NSManagedObjectID *)lineId  withText:(NSString *) newText
{
    NSError *error = nil;
    NSManagedObject *managedLine = nil;
	if (! (managedLine = [self.context existingObjectWithID:lineId error:&error])) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    [managedLine setValue:newText forKey:@"text"];
    
    // Save the context.
    error = nil;
    if (![self.context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
}

- (void) saveLine: (NSManagedObjectID *)lineId withIndent:(NSInteger) newIndent;
{
    NSError *error = nil;
    NSManagedObject *managedLine = nil;
	if (! (managedLine = [self.context existingObjectWithID:lineId error:&error])) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    [managedLine setValue:[NSNumber numberWithInteger:newIndent]  forKey:@"indent"];
    
    // Save the context.
    error = nil;
    if (![self.context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void) changeIndent: (NSManagedObjectID *)lineId indentChange: (NSInteger) indentChange;
{
    NSError *error = nil;
    NSManagedObject *managedLine = nil;
	if (! (managedLine = [self.context existingObjectWithID:lineId error:&error])) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    int currentIndent = [[managedLine valueForKey:@"indent"] integerValue];
    int newIndent = currentIndent + indentChange;
    newIndent = newIndent < 0 ? 0 : newIndent;
    
    [managedLine setValue:[NSNumber numberWithInteger:newIndent]  forKey:@"indent"];
    
    // Save the context.
    error = nil;
    if (![self.context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (BSLine*) getLine: (NSManagedObjectID *)lineId;
{
    NSError *error = nil;
    
    NSManagedObject *managedLine = nil;
	if (! (managedLine = [self.context existingObjectWithID:lineId error:&error])) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    BSLine *line = [[BSLine alloc] init];
    line.text = [[managedLine valueForKey:@"text"] description];
    return line;
}

- (NSManagedObject*) getManagedLine: (NSManagedObjectID *)lineId;
{
    NSError *error = nil;
    
    NSManagedObject *managedLine = nil;
	if (! (managedLine = [self.context existingObjectWithID:lineId error:&error])) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    return managedLine;
}

- (void) setLineOrder:(NSInteger)oldOrder newOrder:(NSInteger) newOrder
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:self.context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"order == %@", oldOrder]];
    NSError *error = nil;
    NSArray *array = [self.context executeFetchRequest:request error:&error];

    NSManagedObject *managedLine = array [0];
    
    [managedLine setValue:[NSNumber numberWithInteger:newOrder] forKey:@"order"];
    
    // Save the context.
    error = nil;
    if (![self.context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void) moveLineFrom:(NSInteger) startPos to:(NSInteger) newPos
{
    if (newPos > startPos){
        for (int i = startPos+1; i < newPos; i ++){
            // decrease order for all items in-between
            [self setLineOrder:i+1 newOrder: i];
        }
        
        // moved object
        [self setLineOrder:startPos newOrder:newPos];
    } else {
        
    }
}

- (void) setCompletedFlag: (NSManagedObjectID *)lineId isCompleted:(Boolean) isCompleted
{
    NSError *error = nil;
    
    NSManagedObject *managedLine = nil;
	if (! (managedLine = [self.context existingObjectWithID:lineId error:&error])) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}

    [managedLine setValue:[NSNumber numberWithBool:isCompleted] forKey:@"isCompleted"];
    
    // Save the context.
    error = nil;
    if (![self.context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void) setProjectFlag: (NSManagedObjectID *)lineId isProject:(Boolean) isProject
{
    NSError *error = nil;
    
    NSManagedObject *managedLine = nil;
	if (! (managedLine = [self.context existingObjectWithID:lineId error:&error])) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    [managedLine setValue:[NSNumber numberWithBool:isProject] forKey:@"isProject"];
    
    // Save the context.
    error = nil;
    if (![self.context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

}

@end
