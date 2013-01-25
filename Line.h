//
//  Line.h
//  BeSharp
//
//  Created by Egor Ovcharenko on 19.01.13.
//  Copyright (c) 2013 Egor Ovcharenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Line : NSManagedObject

@property (nonatomic) int32_t indent;
@property (nonatomic) BOOL isCompleted;
@property (nonatomic) BOOL isProject;
@property (nonatomic) int32_t order;
@property (nonatomic, retain) NSString * text;
@property (nonatomic) int32_t type;
@property (nonatomic) int32_t goalType;
@property (nonatomic) int32_t goalOrder;
@property (nonatomic) int32_t pomodoroExpected;
@property (nonatomic) int32_t pomodoroTaken;
@property (nonatomic, retain) Line *parentProject;

@end
