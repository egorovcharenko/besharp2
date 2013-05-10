//
//  BSSidePanelViewController.m
//  BeSharp
//
//  Created by Egor Ovcharenko on 13.01.13.
//  Copyright (c) 2013 Egor Ovcharenko. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "BSSidePanelViewController.h"

#import "IIViewDeckController.h"

#import "BSMasterViewController.h"
#import "BSDataController.h"
#import "BSGoalLineCell.h"

#import "BSProjectsViewController.h"

#import "Line.h"
#import "consts.h"

@interface BSSidePanelViewController ()

@end

@implementation BSSidePanelViewController

@synthesize focusedTask;
@synthesize timerState;
@synthesize notification;
@synthesize timerStartDate;
@synthesize timerSeconds;


// override setters and getters for focusedTask
-(Line*) focusedTask
{
    return focusedTask;
}

-(void) setFocusedTask:(Line *)newFocusedTask
{
    if (newFocusedTask != nil){
        //self.overallImage.hidden = YES;
        focusedTask = newFocusedTask;
        
        [self updatePomodoroTaskInfo];
        
        // reset the timer
        self.timerState = timerWaitingForWork;
        secondsLeft = secondsWork;
        self.timerLabel.text = [self timeFormatted:secondsLeft];
        
        // Change button skin to disabled
        [self.startStopButton setBackgroundImage:[UIImage imageNamed:@"pomodoro_start.png"] forState:UIControlStateNormal];
        
        // change button label
        [self.startStopButton setTitle: @"Work" forState: UIControlStateNormal];
        
        // Enable the button
        [self.startStopButton setEnabled:YES];
        [self.pomodoroMinusButton setEnabled:YES];
        [self.pomodoroPlusButton setEnabled:YES];
        
        // Set color of task
        [self.focusedTaskTextField setTextColor:[UIColor colorWithRed:254.0/255.0 green:178.0/255.0 blue:51.0/255.0 alpha:1.0]];
        
        // Set color of start button
        [self.startStopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
    } else {
        //self.overallImage.hidden = NO;
        //self.overallImage.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
        
        // Change button skin to disabled
        [self.startStopButton setBackgroundImage:[UIImage imageNamed:@"pomodoro_start_disabled.png"] forState:UIControlStateNormal];
        
        // Disable the buttons
        [self.startStopButton setEnabled:NO];
        [self.pomodoroMinusButton setEnabled:NO];
        [self.pomodoroPlusButton setEnabled:NO];
        
        // Set color of task
        [self.focusedTaskTextField setTextColor:[UIColor grayColor]];
    
        // Set text of task to dummy
        [self.focusedTaskTextField setText:@"Please select the task first"];
        
        // Set color of start button
        [self.startStopButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // reset timer
    self.timerState = timerWaitingForWork;
    
    // set goals table delegate
    self.goalsTable.delegate = self;
    self.goalsTable.dataSource = self;
    
    // hide pomodoro controls
    self.focusedTask = nil;
    
    // set background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pomodoro_background.png"]];
    // set table background
    self.goalsTable.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"projects_background.png"]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    BSMasterViewController *masterViewController = (BSMasterViewController*) self.viewDeckController.centerController;
    switch (section) {
        case 0:
        {
            // daily
            int count = [masterViewController.dataController getGoalsCount:1];
            if (count > 0)
                return 24;
            break;
        }
        case 1:
        {
            // weekly
            int count = [masterViewController.dataController getGoalsCount:2];
            if (count > 0)
                return 24;
            break;
        }
        case 2:
        {
            // yearly
            int count = [masterViewController.dataController getGoalsCount:3];
            if (count > 0)
                return 24;
            break;
        }
        default:
            break;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] init];
    CGFloat width = CGRectGetWidth(self.goalsTable.bounds);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, width, 23)];
    [label setTextAlignment:NSTextAlignmentLeft];
    
    switch (section) {
        case 0:
        {
            [label setText:@"  Daily goals"];
            break;
        }
        case 1:
        {
            [label setText:@"  Weekly goals"];
            break;
        }
        case 2:
        {
            [label setText:@"  Life goals"];
            break;
        }
        default:
            break;
    }
    // set color
    [label setTextColor:[UIColor colorWithRed:163.0/255.0 green:163.0/255.0 blue:163.0/255.0 alpha:1.0]];

    // set back
    [label setBackgroundColor:[UIColor clearColor]];
    [label setShadowOffset:CGSizeMake(0.0, 1.0)];
    [label setShadowColor:[UIColor blackColor]];
    
    [header setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"goals_header_background_simple.png"]]];
    
    [header addSubview:label];
    
    return header;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (Line*) getGoal:(NSIndexPath *)indexPath
{
    BSMasterViewController *masterViewController = (BSMasterViewController*) self.viewDeckController.centerController;
    Line *goal = [masterViewController.dataController getGoal:indexPath.section + 1 number:indexPath.row];
    return goal;
}

- (void)configureCell:(BSGoalLineCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Line *goal = [self getGoal:indexPath];
    
    cell.goalName.text = [NSString stringWithFormat:@"%@", goal.text];

    // add tag to identify clicks
    cell.goalCheckBigButton.tag = ((indexPath.section & 0xFFFF) << 16) | (indexPath.row & 0xFFFF);
    
    if (goal.isCompleted){
        if (!goal.isHidden){
            // if goal is completed but not hidden - draw the checkmark
            [cell.goalCheckMark setBackgroundImage:[UIImage imageNamed:@"checkmarkChecked.png"] forState:UIControlStateNormal];
            
            // set goal name to gray
            [cell.goalName setTextColor: [UIColor colorWithRed:183.0/255.0 green:183.0/255.0 blue:183.0/255.0 alpha:1.0]];
        } else {
            // if goal is hidden - it should not be returned at all
        }
    } else {
        // normal uncompleted goal
        [cell.goalCheckMark setBackgroundImage:[UIImage imageNamed:@"black_checkbox.png"] forState:UIControlStateNormal];
        
        // set goal name to white
        [cell.goalName setTextColor: [UIColor whiteColor]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BSGoalLineCell *cell = [self.goalsTable dequeueReusableCellWithIdentifier:@"GoalCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BSMasterViewController *masterViewController = (BSMasterViewController*) self.viewDeckController.centerController;
    switch (section) {
        case 0:
        {
            int count = [masterViewController.dataController getGoalsCount:1];
            return count;
            break;
        }
        case 1:
        {
            int count = [masterViewController.dataController getGoalsCount:2];
            return count;
            break;
        }
        case 2:
        {
            int count = [masterViewController.dataController getGoalsCount:3];
            return count;
            break;
        }
        default:
            break;
    }
    return 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)inboxButtonClicked:(id)sender {
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    
    //[self.viewDeckController closeLeftView];
    
    //self.viewDeckController.centerController = [storyboard instantiateViewControllerWithIdentifier:@"inboxView"];
}

- (IBAction)projectsButtonClicked:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    
    [self.viewDeckController closeLeftView];
    
    self.viewDeckController.centerController = [storyboard instantiateViewControllerWithIdentifier:@"masterViewController"];

}
- (IBAction)startStopButtonClicked:(id)sender {
    switch (timerState) {
        case timerWaitingForWork:
            
            // remember timer start date
            timerStartDate = [[NSDate alloc] init];
            
            // remember timer time
            timerSeconds = secondsWork;
            
            // setup seconds
            secondsLeft = secondsWork;
            
            // start timer
            timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
            
            // change state
            timerState = timerWorking;
            
            // change button label
            [self.startStopButton setTitle: @"Stop" forState: UIControlStateNormal];
            
            // Change button skin
            [self.startStopButton setBackgroundImage:[UIImage imageNamed:@"pomodoro_stop.png"] forState:UIControlStateNormal];
            
            // Start notification
            [self scheduleNotificationWithText:[NSString stringWithFormat:@"Work finished: %@", focusedTask.text] action:@"rest" interval:secondsLeft];
            
            break;
            
        case timerWorking:
            // stop timer
            [timer invalidate];
            timer = nil;
            
            // setup seconds
            secondsLeft = secondsWork;
            self.timerLabel.text = [self timeFormatted:secondsLeft];
            
            // change state
            timerState = timerWaitingForWork;
            
            // change button label
            [self.startStopButton setTitle: @"Start" forState: UIControlStateNormal];
            
            // Change button skin
            [self.startStopButton setBackgroundImage:[UIImage imageNamed:@"pomodoro_start.png"] forState:UIControlStateNormal];
            
            // Cancel notification
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            
            break;
            
        case timerWaitingForRest:
            
            // remember timer start date
            timerStartDate = [[NSDate alloc] init];
            
            // remember timer time
            timerSeconds = secondsRest;
            
            // setup seconds
            secondsLeft = secondsRest;
            
            // start timer
            timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
            
            // change state
            timerState = timerResting;
            
            // change button label
            [self.startStopButton setTitle: @"Skip" forState: UIControlStateNormal];

            // Change button skin
            [self.startStopButton setBackgroundImage:[UIImage imageNamed:@"pomodoro_skip.png"] forState:UIControlStateNormal];
            
            // Start notification
            [self scheduleNotificationWithText:[NSString stringWithFormat:@"Rest finished after: %@", focusedTask.text] action:@"continue work" interval:secondsLeft];
            
            break;
            
        case timerResting:
            // skip to work
            [self prepareForWork];
            
            // Cancel notification
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            
            break;

        default:
            break;
    }
    
}

- (void)prepareForWork {
    // reset timer
    if (timer){
        [timer invalidate];
        timer = nil;
    }
    
    // set state
    timerState = timerWaitingForWork;
    
    // set seconds
    secondsLeft = secondsWork;
    self.timerLabel.text = [self timeFormatted:secondsLeft];
    
    // change button label
    [self.startStopButton setTitle: @"Start" forState: UIControlStateNormal];
    
    // Change button skin
    [self.startStopButton setBackgroundImage:[UIImage imageNamed:@"pomodoro_start.png"] forState:UIControlStateNormal];
}

- (void)saveFocusedTask {
    // save task
    [self saveTask:focusedTask];
}

- (void) saveTask : (Line*) taskToSave
{
    // save task
    BSMasterViewController *masterViewController = (BSMasterViewController*) self.viewDeckController.centerController;
    [masterViewController.dataController saveLine:taskToSave];
}

-(void) flashScreen {
    UIWindow* wnd = [UIApplication sharedApplication].keyWindow;
    UIView* v = [[UIView alloc] initWithFrame: CGRectMake(0, 0, wnd.frame.size.width, wnd.frame.size.height)];
    [wnd addSubview: v];
    v.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7];
    
    // run some code after smooth update
    [CATransaction begin];
    
    [CATransaction setCompletionBlock:^{
        // remove view from superview
        [v removeFromSuperview];
    }];
    
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration: 1.0];
    v.alpha = 0.0f;
    [UIView commitAnimations];
    
    [CATransaction commit];
}

- (void) timerTick:(NSTimer *) argTimer {
    // update seconds left
    //secondsLeft --;
    NSDate *now = [[NSDate alloc] init];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSSecondCalendarUnit|NSMinuteCalendarUnit|NSHourCalendarUnit
                                               fromDate:timerStartDate
                                                 toDate:now
                                                options:0];

    int secondsElapsed = [components second] + [components minute] * 60;
    secondsLeft =  timerSeconds - secondsElapsed;
    
    // if it's the end
    if (secondsLeft <=0) {
        
        // flash the screen
        [self flashScreen];
        
        switch (timerState) {
                // work period finished
            case timerWorking:
            {
                // reset timer
                [timer invalidate];
                timer = nil;
                
                // set state
                timerState = timerWaitingForRest;
                
                // add pomodoro to task;
                focusedTask.pomodoroUsed ++;
                if (focusedTask.pomodoroUsed > focusedTask.pomodoroTotal)
                    focusedTask.pomodoroTotal = focusedTask.pomodoroUsed;
                
                // save task
                [self saveFocusedTask];
                
                // refresh screen
                [self updatePomodoroTaskInfo];
                
                // set seconds
                secondsLeft = secondsRest;
                self.timerLabel.text = [self timeFormatted:secondsLeft];
                
                // change button label
                [self.startStopButton setTitle: @"Rest" forState: UIControlStateNormal];
                
                // Change button skin
                [self.startStopButton setBackgroundImage:[UIImage imageNamed:@"pomodoro_start.png"] forState:UIControlStateNormal];
                
                // Cancel notification
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
                
                break;
            }
                // rest finished
            case timerResting:
            {
                // start waiting for work
                [self prepareForWork];
                
                // Cancel notification
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
                
                break;
            }
            default:
                break;
        }
        
    }
    
    // update the label
    self.timerLabel.text = [self timeFormatted:secondsLeft];
}

- (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}
- (IBAction)increaseLeftClicked:(id)sender {
    // increase number of pomodoros left
    focusedTask.pomodoroTotal ++;
    
    // save task
    [self saveFocusedTask];
    
    // refresh screen
    [self updatePomodoroTaskInfo];
}

- (IBAction)decreaseLeftClicked:(id)sender {
    // decrease number of pomodoros left
    if(focusedTask.pomodoroTotal > focusedTask.pomodoroUsed){
        focusedTask.pomodoroTotal --;
        if(focusedTask.pomodoroTotal < 0)
            focusedTask.pomodoroTotal = 0;
    }
    
    // save task
    [self saveFocusedTask];
    
    // refresh screen
    [self updatePomodoroTaskInfo];
}

-(void)updatePomodoroTaskInfo
{
    // refresh task
    self.focusedTaskTextField.text = self.focusedTask.text;
    
    // TODO set maximum allowed height for the field
    //CGSize textViewSize = [self.focusedTask.text sizeWithFont:self.focusedTaskTextField.font constrainedToSize:CGSizeMake(self.focusedTaskTextField.frame.size.width, FLT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    //self.focusedTaskTextFieldHeightConstraint.constant = textViewSize.height;
    
    // display left pomodoros
    int leftPomodoro = focusedTask.pomodoroTotal - focusedTask.pomodoroUsed;
    if (leftPomodoro < 0)
        leftPomodoro = 0;
    
    self.leftPomodorosLabel.text = [NSString stringWithFormat:@"%d", leftPomodoro];
    
    // display completed pomodoros    
    self.completedPomodorosLabel.text = [NSString stringWithFormat:@"%d", focusedTask.pomodoroUsed];
    
}

- (IBAction)goalCompleteClicked:(UIButton*)sender forEvent:(UIEvent *)event {
    // restore index from the tag
    NSUInteger section = ((sender.tag >> 16) & 0xFFFF);
    NSUInteger row     = (sender.tag & 0xFFFF);
    NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:section];
    
    // get goal
    Line* goal = [self getGoal:index];
    
    if (!goal.isCompleted){
        // set task as completed
        goal.isCompleted = YES;
    } else {
        // set task as not completed
        goal.isCompleted = NO;
    }
    
    // save goal
    [self saveTask:goal];
    
    // refresh (possibly not needed)
    [self.goalsTable reloadData];
    
    // reload center and project screens also
    BSMasterViewController *centerController = (BSMasterViewController*) self.viewDeckController.centerController;
    [centerController.tableView reloadData];
    
    BSProjectsViewController *rightController = (BSProjectsViewController*) self.viewDeckController.rightController;
    [rightController.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // set task as focused
    Line* selectedGoal = [self getGoal:indexPath];
    self.focusedTask = selectedGoal;
}

- (void)scheduleNotificationWithText:(NSString *)text action:(NSString*)action interval:(int)secondsAfter {
    // get current date
    NSDate *now = [[NSDate alloc] init];
    
    notification = [[UILocalNotification alloc] init];
    if (notification == nil)
        return;
    
    notification.fireDate = [now dateByAddingTimeInterval:secondsAfter];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    
    notification.alertBody = text;
    notification.alertAction = action;
    
    notification.soundName = UILocalNotificationDefaultSoundName;
    //notification.applicationIconBadgeNumber = 1;
    
    //NSDictionary *infoDict = [NSDictionary dictionaryWithObject:item.eventName forKey:ToDoItemKey];
    //localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end