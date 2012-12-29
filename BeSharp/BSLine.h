//
//  BSLine.h
//  BeSharp
//
//  Created by Egor Ovcharenko on 28.12.12.
//  Copyright (c) 2012 Egor Ovcharenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BSLine : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic) NSInteger *order;
@property (nonatomic) NSInteger *indent;
@property (nonatomic) BOOL isProject;
@property (nonatomic) BOOL isCompleted;
@property (nonatomic) NSInteger projectId;

@end
