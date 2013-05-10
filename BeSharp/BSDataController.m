//
//  BSDataController.m
//  BeSharp
//
//  Created by Egor Ovcharenko on 28.12.12.
//  Copyright (c) 2012 Egor Ovcharenko. All rights reserved.
//

#import "BSDataController.h"
#import "BSAppDelegate.h"
#import "Line.h"

/*
 
 type:
 1 - line
 2 - project
 3 - inbox
 
 goalType:
 1 - daily
 2 - weekly
 3 - year
 4 - life (reserved)
 */



@implementation BSDataController

-(BSDataController*) initWithAppDelegate:(BSAppDelegate *)delegate fetchedControllerDelegate:(NSObject <NSFetchedResultsControllerDelegate>*)fetchedResultsControllerDelegate;
{
    _context = [delegate managedObjectContext];
    _fetchedResultsControllerDelegate = fetchedResultsControllerDelegate;
    return self;
}

-(BSDataController*) initWithAppDelegate:(BSAppDelegate *)delegate;
{
    _context = [delegate managedObjectContext];
    return self;
}

-(Line*) createNewLineForSaving
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:self.context];
    Line *newManagedLine = [[Line alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:self.context];
    return newManagedLine;
}

-(int) saveLine:(Line *)newLine
{
    int result = newLine.order;
    
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
            newLine.order = count;
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
    NSFetchedResultsController *fetchedResultsController;
    fetchedResultsController = [self getAllLinesInternal:0];
    fetchedResultsController.delegate = self;
    
	NSError *error = nil;
	if (![fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return fetchedResultsController;
}

-(NSFetchedResultsController*) getAllLinesInternal:(NSInteger)lineType
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"(isHidden = NO) AND (type = %@)", lineType];
    [fetchRequest setPredicate:filterPredicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    
    return aFetchedResultsController;
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

- (NSFetchedResultsController *) getAllLinesFromProject:(Line*)project
{
    return [self getAllLinesFromProject:project lineType:1];
}

- (NSFetchedResultsController *) getAllLinesFromProject:(Line*)project lineType:(NSInteger)lineType
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    NSPredicate *filterPredicate;
    if (project != nil){
        filterPredicate = [NSPredicate predicateWithFormat:@"(isHidden = NO) AND (type = %d) AND (parentProject = %@)", lineType, project];
    } else {
        filterPredicate = [NSPredicate predicateWithFormat:@"(isHidden = NO) AND (type = %d) AND (parentProject = %@)", lineType, project];
    }
    [fetchRequest setPredicate:filterPredicate];
    
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    
    fetchResultsController.delegate = self;
    
    // temp
    NSError *error = nil;
    //NSArray* temp = [self.context executeFetchRequest:fetchRequest error:&error];
    //int tempCount = temp.count;
    
    [fetchResultsController performFetch:&error];
    //int anotherCount = [fetchResultsController.fetchedObjects count];
    
    return fetchResultsController;
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

- (Line*) getManagedLine: (NSManagedObjectID *)lineId;
{
    NSError *error = nil;
    
    Line *managedLine = nil;
	if (! (managedLine = (Line*)[self.context existingObjectWithID:lineId error:&error])) {
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

- (void) moveLineFrom:(NSInteger) startPos to:(NSInteger) newPos inProject:(Line*) parentProject
{
    [self normalizeOrder:parentProject];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"(isHidden = NO) AND (parentProject == %@)", parentProject]];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *lines = [self.context executeFetchRequest:request error:&error];
    
    if (newPos > startPos){
        // decrease order for all items in-between
        for (int i = startPos + 1; i <= newPos; i ++){
            Line* line = [lines objectAtIndex:(i)];
            line.order --;
        }
        
        // moved object - move to end position
        Line *draggedLine = [lines objectAtIndex:startPos];
        draggedLine.order = newPos + 1;
        
    } else {
        // increse order for all items in-between
        for (int i = newPos; i < startPos; i ++){
            Line* line = [lines objectAtIndex:(i)];
            line.order ++;
        }
        
        // moved object - move to end position
        Line *draggedLine = [lines objectAtIndex:startPos];
        draggedLine.order = newPos + 1;
    }
    
    // save changes
    [self saveContext];
}

- (void) moveProjectFrom:(NSInteger)startPos to:(NSInteger)newPos
{
    [self normalizeProjectsOrder];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"(isHidden = NO) AND (type == 2)"]];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *lines = [self.context executeFetchRequest:request error:&error];
    
    if (newPos > startPos){
        // decrease order for all items in-between
        for (int i = startPos + 1; i <= newPos; i ++){
            Line* line = [lines objectAtIndex:(i)];
            line.order --;
        }
        
        // moved object - move to end position
        Line *draggedLine = [lines objectAtIndex:startPos];
        draggedLine.order = newPos + 1;
        
    } else {
        // increse order for all items in-between
        for (int i = newPos; i < startPos; i ++){
            Line* line = [lines objectAtIndex:(i)];
            line.order ++;
        }
        
        // moved object - move to end position
        Line *draggedLine = [lines objectAtIndex:startPos];
        draggedLine.order = newPos + 1;
    }
    
    // save changes
    [self saveContext];

}

- (void) normalizeOrder:(Line*) parentProject
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"(isHidden = NO) AND (parentProject == %@) AND (type == 1)", parentProject]];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *lines = [self.context executeFetchRequest:request error:&error];
    
    // normalize
    for (int i = 0; i < lines.count; i ++){
        Line* line = [lines objectAtIndex:i];
        line.order = i + 1;
    }
    
    // save changes
    [self saveContext];
}

- (void) normalizeProjectsOrder
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"(isHidden = NO) AND (type == 2)"]];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *lines = [self.context executeFetchRequest:request error:&error];
    
    // normalize
    for (int i = 0; i < lines.count; i ++){
        Line* line = [lines objectAtIndex:i];
        line.order = i + 1;
    }
    
    // save changes
    [self saveContext];
}


- (void)saveContext
{
    // Save the context.
    NSError *error;
    error = nil;
    if (![self.context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (Line*) getInbox
{
    Line* result = [self getInboxInternal];
    
    if(result == nil){
        // create inbox if it's not created yet
        Line *line = [self createNewLineForSaving];
        line.text = @"Inbox";
        line.type = 3;
        line.parentProject = nil;
        
        [self saveLine:line];
        
        // rerun query
        result = [self getInboxInternal];
    }
    return result;
}

- (Line*) getInboxInternal
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"type == 3"];
    [fetchRequest setPredicate:filterPredicate];
    
    NSError *error = nil;
    NSArray *array = [self.context executeFetchRequest:fetchRequest error:&error];
    
    if (array.count == 0){
        return nil;
    }
    return array [0];
}

-(NSInteger) lastGoalOrderByType:(NSInteger) goalType
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"goalType = 1"];
    [fetchRequest setPredicate:filterPredicate];
    
    NSError *error = nil;
    NSArray *array = [self.context executeFetchRequest:fetchRequest error:&error];
    
    if (array.count == 0){
        return 0;
    }
    
    NSInteger result = [[array valueForKeyPath:@"@max.goalOrder"] integerValue];
    
    return result;
}

- (NSArray *)getGoalsByType:(NSInteger)goalType
{
    return [self getGoalsByType:goalType returnHidden:NO];
}

- (NSArray *)getGoalsByType:(NSInteger)goalType returnHidden:(Boolean)returnHidden
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *filterPredicate;
    if (returnHidden == NO){
        filterPredicate = [NSPredicate predicateWithFormat:@"(goalType = %d) AND (isHidden = NO)", goalType];
    } else {
        filterPredicate = [NSPredicate predicateWithFormat:@"(goalType = %d) AND (isHidden = YES)", goalType];
    }
    [fetchRequest setPredicate:filterPredicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"goalOrder" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *array = [self.context executeFetchRequest:fetchRequest error:&error];
    return array;
}

// number: zero-based
- (Line*) getGoal:(NSInteger)goalType number:(NSInteger)number
{
    NSArray *array;
    array = [self getGoalsByType:goalType];
    
    if (array.count <= number){
        return nil;
    }
    
    return array[number];
}

- (NSInteger) getGoalsCount:(NSInteger)goalType
{
    NSArray *array;
    array = [self getGoalsByType:goalType];
    return array.count;
}

- (void) addOrderToAllLinesStartingOrder: (int) startinOrder fromProject:(Line*) parentProject
{
    NSFetchedResultsController *allLinesFromProject = [self getAllLinesFromProject:parentProject];
    for (Line *line in [allLinesFromProject fetchedObjects]){
        if (line.order >= startinOrder){
            line.order ++;
        }
    }
    [self saveContext];
}

- (NSArray*) hideAllCompletedLinesFromProject: (Line*) parentProject actuallyHide:(Boolean) actuallyHide
{
    NSMutableArray *result=[[NSMutableArray alloc]init];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *filterPredicate;
    filterPredicate = [NSPredicate predicateWithFormat:@"(isHidden = NO) AND (parentProject = %@)", parentProject];
    [fetchRequest setPredicate:filterPredicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *completedLines = [self.context executeFetchRequest:fetchRequest error:&error];
    
    int i = 0;
    // iterate over all returned lines
    for (Line *line in completedLines) {
        if (line.isCompleted){
            if (actuallyHide == YES) {
            // change isHidden to YES
                line.isHidden = YES;
            }
            
            // remember this line in return array
            NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
            [result addObject:ip];
        }
        
        // increase anyway
        i ++;
    }
    
    // save context
    [self saveContext];
    
    return result;
}

- (NSArray*) hideAllCompletedProjects:(Boolean) actuallyHide
{
    NSMutableArray *result=[[NSMutableArray alloc]init];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *filterPredicate;
    filterPredicate = [NSPredicate predicateWithFormat:@"(type = 2) AND (isHidden = NO)"];
    [fetchRequest setPredicate:filterPredicate];
    
    NSError *error = nil;
    NSArray *completedLines = [self.context executeFetchRequest:fetchRequest error:&error];
    
    int i = 0;
    // iterate over all returned lines
    for (Line *line in completedLines) {
        if (line.isCompleted){
            if (actuallyHide == YES) {
                // change isHidden to YES
                line.isHidden = YES;
            }
            
            // remember this line in return array
            NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
            [result addObject:ip];
        }
        
        // increase anyway
        i ++;
    }
    
    // save context
    [self saveContext];
    
    return result;
}

- (NSInteger) findNumberOfChildren:(Line*) mainLine parentProject:(Line*)parentProject
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *filterPredicate;
    filterPredicate = [NSPredicate predicateWithFormat:@"(isHidden = NO) AND (parentProject = %@)", parentProject];
    [fetchRequest setPredicate:filterPredicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *lines = [self.context executeFetchRequest:fetchRequest error:&error];
    
    bool counting = false;
    NSInteger result = 0;
    
    // iterate over all returned lines
    for (Line *line in lines) {
        NSLog(@"%@, i:%i", line.text, line.indent);
        if (line.order == mainLine.order){
            counting = true;
        } else if (counting){
            if(line.indent > mainLine.indent){
                result ++;
            }
            else
                return result;
        }
    }
    return result;
}

- (NSInteger) numberOfCheckedLines:(Line*)parentProject
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *filterPredicate;
    filterPredicate = [NSPredicate predicateWithFormat:@"(isHidden = NO) AND (parentProject = %@) AND (isCompleted = YES)", parentProject];
    [fetchRequest setPredicate:filterPredicate];

    NSError *err;
    NSUInteger count = [self.context countForFetchRequest:fetchRequest error:&err];

    if (count == NSNotFound) {
        return 0;
    } else {
        return count;
    }
}

- (NSInteger) numberOfCheckedProjects
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Line" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *filterPredicate;
    filterPredicate = [NSPredicate predicateWithFormat:@"(type = 2) AND (isCompleted = YES) AND (isHidden = NO)"];
    [fetchRequest setPredicate:filterPredicate];
    
    NSError *err;
    NSUInteger count = [self.context countForFetchRequest:fetchRequest error:&err];
    
    if (count == NSNotFound) {
        return 0;
    } else {
        return count;
    }
}

@end
