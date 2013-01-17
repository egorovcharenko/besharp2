//
//  BSLineCell.m
//  BeSharp
//
//  Created by Egor Ovcharenko on 06.01.13.
//  Copyright (c) 2013 Egor Ovcharenko. All rights reserved.
//

#import "BSLineCell.h"

@implementation BSLineCell

@synthesize textFieldForEdit;
@synthesize textLabel;
@synthesize indentView;
@synthesize leftButton;
@synthesize indentInPixels;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)leftButtonClicked:(id)sender {
}
@end
