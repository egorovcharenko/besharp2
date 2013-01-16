//
//  BSSidePanelViewController.m
//  BeSharp
//
//  Created by Egor Ovcharenko on 13.01.13.
//  Copyright (c) 2013 Egor Ovcharenko. All rights reserved.
//

#import "BSSidePanelViewController.h"

#import "IIViewDeckController.h"

#import "BSInboxViewController.h"

@interface BSSidePanelViewController ()

@end

@implementation BSSidePanelViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)inboxButtonClicked:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    
    [self.viewDeckController closeLeftView];
    
    self.viewDeckController.centerController = [storyboard instantiateViewControllerWithIdentifier:@"inboxView"];
}

- (IBAction)projectsButtonClicked:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    
    [self.viewDeckController closeLeftView];
    
    self.viewDeckController.centerController = [storyboard instantiateViewControllerWithIdentifier:@"masterViewController"];

}
@end
