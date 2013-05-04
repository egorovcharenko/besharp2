//
//  BSSidePanelViewController.m
//  BeSharp
//
//  Created by Egor Ovcharenko on 13.01.13.
//  Copyright (c) 2013 Egor Ovcharenko. All rights reserved.
//

#import "BSSidePanelViewController.h"

#import "IIViewDeckController.h"

#import "BSMasterViewController.h"
#import "BSDataController.h"
#import "BSGoalLineCell.h"

#import "Line.h"
#import "consts.h"

@interface BSSidePanelViewController ()

@end

@implementation BSSidePanelViewController

@synthesize focusedTask;
@synthesize timerState;

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
        
        // Enable the button
        [self.startStopButton setEnabled:YES];
        [self.pomodoroMinusButton setEnabled:YES];
        [self.pomodoroPlusButton setEnabled:YES];
        
        // Set color of task
        [self.focusedTaskTextField setTextColor:[UIColor colorWithRed:254.0/255.0 green:178.0/255.0 blue:51.0/255.0 alpha:1.0]];
        
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
        [self.focusedTaskTextField setText:@"Please select task first"];
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
    
    // hide pomodoro controls behind the image
    self.focusedTask = nil;
    
    // set background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pomodoro_background.png"]];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    BSMasterViewController *masterViewController = (BSMasterViewController*) self.viewDeckController.centerController;
    switch (section) {
        case 0:
        {
            int count = [masterViewController.dataController getGoalsCount:1];
            if (count > 0)
                return 20;
            break;
        }
        case 1:
        {
            int count = [masterViewController.dataController getGoalsCount:2];
            if (count > 0)
                return 20;
            break;
        }
        case 2:
        {
            int count = [masterViewController.dataController getGoalsCount:3];
            if (count > 0)
                return 20;
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
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, width, 20)];
    [label setTextAlignment:NSTextAlignmentLeft];
    
    switch (section) {
        case 0:
        {
            [label setText:@"Daily goals"];
            break;
        }
        case 1:
        {
            [label setText:@"Weekly goals"];
            break;
        }
        case 2:
        {
            [label setText:@"Life goals"];
            break;
        }
        default:
            break;
    }
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
    Line *goal = [masterViewController.dataController getGoal:indexPath.section+1 number:indexPath.row];
    return goal;
}

- (void)configureCell:(BSGoalLineCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Line *goal = [self getGoal:indexPath];
    
    cell.goalName.text = [NSString stringWithFormat:@"%@", goal.text];

    // add tag to identify clicks
    //cell.leftButton.tag = ((indexPath.section & 0xFFFF) << 16) | (indexPath.row & 0xFFFF);
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
            
            break;
            
        case timerWaitingForRest:
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
            
            break;
            
        case timerResting:
            // skip to work
            [self prepareForWork];
            
            
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
    BSMasterViewController *masterViewController = (BSMasterViewController*) self.viewDeckController.centerController;
    [masterViewController.dataController saveLine:focusedTask];
}

- (void) timerTick:(NSTimer *) argTimer {
    // update seconds left
    secondsLeft --;
    
    // if it's the end
    if (secondsLeft <=0) {
        switch (timerState) {
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
                
                break;
            }
            case timerResting:
            {
                // start waiting for work
                
                [self prepareForWork];
                
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
    CGSize textViewSize = [self.focusedTask.text sizeWithFont:self.focusedTaskTextField.font constrainedToSize:CGSizeMake(self.focusedTaskTextField.frame.size.width, FLT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    //self.focusedTaskTextFieldHeightConstraint.constant = textViewSize.height;
    
    // display left pomodoros
    int leftPomodoro = focusedTask.pomodoroTotal - focusedTask.pomodoroUsed;
    if (leftPomodoro < 0)
        leftPomodoro = 0;
    
    self.leftPomodorosLabel.text = [NSString stringWithFormat:@"%d", leftPomodoro];
    
    // display completed pomodoros    
    self.completedPomodorosLabel.text = [NSString stringWithFormat:@"%d", focusedTask.pomodoroUsed];
    
}
@end
