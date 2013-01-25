//
//  BSInitialViewController.m
//  BeSharp
//
//  Created by Egor Ovcharenko on 13.01.13.
//  Copyright (c) 2013 Egor Ovcharenko. All rights reserved.
//

#import "BSInitialViewController.h"

#import "IIViewDeckController.h"

@interface BSInitialViewController ()

@end

@implementation BSInitialViewController

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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    self = [super initWithCenterViewController:[storyboard instantiateViewControllerWithIdentifier:@"masterViewController"]
            leftViewController:[storyboard instantiateViewControllerWithIdentifier:@"sidePanel"]
            rightViewController:[storyboard instantiateViewControllerWithIdentifier:@"projectsList"]
            ];
    
    // disable centerview when side is opened
    self.centerhiddenInteractivity = IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose;
    
    if (self) {
        // Add any extra init code here
    }
    return self;
}

@end
