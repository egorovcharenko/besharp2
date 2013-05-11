//
//  BSAppDelegate.m
//  BeSharp
//
//  Created by Egor Ovcharenko on 28.12.12.
//  Copyright (c) 2012 Egor Ovcharenko. All rights reserved.
//

#import "BSAppDelegate.h"

#import "BSDataController.h"
#import "Line.h"

#import "BSMasterViewController.h"

@implementation BSAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
    } else {
    }
    
    // pre-load DB with tutorial data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"firstRun"])
    {
        [defaults setObject:[NSDate date] forKey:@"firstRun"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self preloadTutorialData];
    }
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BeSharp" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BeSharp.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notif {
    application.applicationIconBadgeNumber = 0;
}

- (void) preloadTutorialData
{
    BSDataController *dataController = [[BSDataController alloc] initWithAppDelegate:self];
    
    // add tutorial projects
    Line* tutorial1 = [dataController createNewLineForSaving];
    tutorial1.text = @"Tutorial 1: basics";
    tutorial1.order = 1;
    tutorial1.parentProject = nil;
    tutorial1.type = 2;
    [dataController saveLine:tutorial1];
    
    Line* tutorial2 = [dataController createNewLineForSaving];
    tutorial2.text = @"Tutorial 2: focus";
    tutorial2.order = 2;
    tutorial2.parentProject = nil;
    tutorial2.type = 2;
    [dataController saveLine:tutorial2];
    
    Line* tutorial3 = [dataController createNewLineForSaving];
    tutorial3.text = @"Tutorial 3: goals";
    tutorial3.order = 3;
    tutorial3.parentProject = nil;
    tutorial3.type = 2;
    [dataController saveLine:tutorial3];
    
    Line* tutorial4 = [dataController createNewLineForSaving];
    tutorial4.text = @"Tutorial 4: typical workflow";
    tutorial4.order = 4;
    tutorial4.parentProject = nil;
    tutorial4.type = 2;
    [dataController saveLine:tutorial4];
    
    // add lines to inbox
    Line *line = [dataController createNewLineForSaving];
    line.text = @"Welcome to BeSharp - the tool that helps you keep focused!";
    line.order = 1;
    line.parentProject = [dataController getInbox];
    line.type = 1;
    [dataController saveLine:line];
    
    line = [dataController createNewLineForSaving];
    line.text = @"Swipe to the left to reveal Projects screen on the right. Then select the first Tutorial project";
    line.order = 2;
    line.parentProject = [dataController getInbox];
    line.type = 1;
    [dataController saveLine:line];
    
    line = [dataController createNewLineForSaving];
    line.text = @"Tip: delete all these tasks if you wish";
    line.order = 3;
    line.parentProject = [dataController getInbox];
    line.type = 1;
    [dataController saveLine:line];
    
    
    
    // Tutorial 1 - basics
    line = [dataController createNewLineForSaving];
    line.text = @"Each line is a task. Complete it by tapping checkbox. You can delete all completed tasks by tapping the 'Delete' button at the top";
    line.order = 1; line.parentProject = tutorial1; line.type = 1; [dataController saveLine:line];
    
    line = [dataController createNewLineForSaving];
    line.text = @"Projects are there to group tasks. You can complete them in the similar way";
    line.order = 2; line.parentProject = tutorial1; line.type = 1; [dataController saveLine:line];
    
    line = [dataController createNewLineForSaving];
    line.text = @"Tap any task to see the popup menu. For projects - tap right pencil icon";
    line.order = 3; line.parentProject = tutorial1; line.type = 1; [dataController saveLine:line];
    
    line = [dataController createNewLineForSaving];
    line.text = @"Create new tasks using buttons with a '+' sign in the popup menu or text area in the bottom";
    line.order = 4; line.parentProject = tutorial1; line.type = 1; [dataController saveLine:line];
    
    line = [dataController createNewLineForSaving];
    line.text = @"Move task to a diffent project by selecting top-right button in the popup menu";
    line.order = 5; line.parentProject = tutorial1; line.type = 1; [dataController saveLine:line];
    
    line = [dataController createNewLineForSaving];
    line.text = @"Change indent of a task by using right and left arrows in the popup menu";
    line.order = 6; line.parentProject = tutorial1; line.type = 1; [dataController saveLine:line]; line.indent = 1;
    
    line = [dataController createNewLineForSaving];
    line.text = @"Reorder tasks and projects by long-tapping them and then dragging";
    line.order = 7; line.parentProject = tutorial1; line.type = 1; [dataController saveLine:line]; ;
    
    
    
    // Tutorial 2 - focus
    line = [dataController createNewLineForSaving];
    line.text = @"Focusing is what makes BeSharp special";
    line.order = 1; line.parentProject = tutorial2; line.type = 1; [dataController saveLine:line];
    
    line = [dataController createNewLineForSaving];
    line.text = @"Focusing means working without any distractions for 25 minutes, and then having 5 minutes rest before next 'sprint'";
    line.order = 2; line.parentProject = tutorial2; line.type = 1; [dataController saveLine:line];
    
    line = [dataController createNewLineForSaving];
    line.text = @"Let me repeat - you cannot distract at all during 25 minutes. It's what helps you to stay productive";
    line.order = 3; line.parentProject = tutorial2; line.type = 1; [dataController saveLine:line];
    
    line = [dataController createNewLineForSaving];
    line.text = @"You pick a task to focus on by either using top-left icon from the popup menu, or by selecting a goal (discussed later)";
    line.order = 4; line.parentProject = tutorial2; line.type = 1; [dataController saveLine:line];
    
    line = [dataController createNewLineForSaving];
    line.text = @"Start working on a task by tapping 'start' button. After timer finished, have a rest";
    line.order = 5; line.parentProject = tutorial2; line.type = 1; [dataController saveLine:line];
    
    line = [dataController createNewLineForSaving];
    line.text = @"If you lose focus - click 'stop' and start over";
    line.order = 6; line.parentProject = tutorial2; line.type = 1; [dataController saveLine:line];
    
    
    
    
    // Tutorial 3 - goals
    line = [dataController createNewLineForSaving];
    line.text = @"Goals help you keep focus on most important tasks. There are daily, weekly and yearly goals";
    line.order = 1; line.parentProject = tutorial3; line.type = 1; [dataController saveLine:line];
    
    line = [dataController createNewLineForSaving];
    line.text = @"Daily goals are tasks; weekly and yearly are projects";
    line.order = 2; line.parentProject = tutorial3; line.type = 1; [dataController saveLine:line];
    
    line = [dataController createNewLineForSaving];
    line.text = @"Mark task as a daily goal by tapping lower-left button in it's popup menu";
    line.order = 3; line.parentProject = tutorial3; line.type = 1; [dataController saveLine:line];
    
    line = [dataController createNewLineForSaving];
    line.text = @"Goals are shown in the left (focus) panel. You can focus on them by tapping";
    line.order = 4; line.parentProject = tutorial3; line.type = 1; [dataController saveLine:line];
    
    line = [dataController createNewLineForSaving];
    line.text = @"Mark projects as weekly and yearly goals in the popup menu";
    line.order = 5; line.parentProject = tutorial3; line.type = 1; [dataController saveLine:line];
    
    line = [dataController createNewLineForSaving];
    line.text = @"Try to have no more than 3 goals of each type - it helps you keep them in your view";
    line.order = 6; line.parentProject = tutorial3; line.type = 1; [dataController saveLine:line]; 
    
    
    
    
    // Tutorial 4 - typical workflow
    line = [dataController createNewLineForSaving];
    line.text = @"All your task first usually should be captured in the 'Inbox'";
    line.order = 1; line.parentProject = tutorial4; line.type = 1; [dataController saveLine:line];
    
    line = [dataController createNewLineForSaving];
    line.text = @"Several times per day, free up inbox by moving tasks to the corresponding projects";
    line.order = 2; line.parentProject = tutorial4; line.type = 1; [dataController saveLine:line];
    
    line = [dataController createNewLineForSaving];
    line.text = @"At evening, select 2-4 daily goals for the next day";
    line.order = 3; line.parentProject = tutorial4; line.type = 1; [dataController saveLine:line];
    
    line = [dataController createNewLineForSaving];
    line.text = @"Next day, start doing your daily goals FIRST";
    line.order = 4; line.parentProject = tutorial4; line.type = 1; [dataController saveLine:line];
    
    line = [dataController createNewLineForSaving];
    line.text = @"Same principles apply for weekly and yearly goals";
    line.order = 5; line.parentProject = tutorial4; line.type = 1; [dataController saveLine:line];
    
    line = [dataController createNewLineForSaving];
    line.text = @"Now you can delete these tutorial projects or leave them for reference. Good luck and be productive!";
    line.order = 6; line.parentProject = tutorial4; line.type = 1; [dataController saveLine:line];
    
}

@end
