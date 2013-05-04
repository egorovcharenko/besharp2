//
//  BSSidePanelViewController.h
//  BeSharp
//
//  Created by Egor Ovcharenko on 13.01.13.
//  Copyright (c) 2013 Egor Ovcharenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Line;

@interface BSSidePanelViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
    NSTimer *timer;
    NSInteger secondsLeft;
}
- (IBAction)inboxButtonClicked:(id)sender;
- (IBAction)projectsButtonClicked:(id)sender;

// pomodoro
@property Line *focusedTask;

@property (weak, nonatomic) IBOutlet UILabel *focusedTaskTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *focusedTaskTextFieldHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
- (IBAction)startStopButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *startStopButton;
@property (weak, nonatomic) IBOutlet UILabel *completedPomodorosLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftPomodorosLabel;
- (IBAction)increaseLeftClicked:(id)sender;
- (IBAction)decreaseLeftClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *overallImage;
@property (weak, nonatomic) IBOutlet UIButton *pomodoroMinusButton;
@property (weak, nonatomic) IBOutlet UIButton *pomodoroPlusButton;

typedef enum {
    timerWaitingForWork,
    timerWorking,
    timerWaitingForRest,
    timerResting
} TimerEnum;

@property TimerEnum timerState;

// goals
@property (weak, nonatomic) IBOutlet UITableView *goalsTable;


@end
