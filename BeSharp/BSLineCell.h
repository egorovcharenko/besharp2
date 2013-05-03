//
//  BSLineCell.h
//  BeSharp
//
//  Created by Egor Ovcharenko on 06.01.13.
//  Copyright (c) 2013 Egor Ovcharenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSLineCell : UITableViewCell

// general controls
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UITextField *textFieldForEdit;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;

// for projects
@property (weak, nonatomic) IBOutlet UIButton *leftButtonProjects;

// indent
@property NSInteger indentInPixels;

@end
