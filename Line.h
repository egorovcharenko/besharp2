//
//  Line.h
//  BeSharp
//
//  Created by Egor Ovcharenko on 26.01.13.
//  Copyright (c) 2013 Egor Ovcharenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Line;

@interface Line : NSManagedObject

@property (nonatomic) int32_t goalOrder;
@property (nonatomic) int32_t goalType;
@property (nonatomic) int32_t indent;
@property (nonatomic) BOOL isCompleted;
@property (nonatomic) int32_t order;
@property (nonatomic) int32_t pomodoroTotal;
@property (nonatomic) int32_t pomodoroUsed;
@property (nonatomic, retain) NSString * text;
@property (nonatomic) int32_t type;
@property (nonatomic, retain) NSSet *childLines;
@property (nonatomic, retain) Line *parentProject;
@end

@interface Line (CoreDataGeneratedAccessors)

- (void)addChildLinesObject:(Line *)value;
- (void)removeChildLinesObject:(Line *)value;
- (void)addChildLines:(NSSet *)values;
- (void)removeChildLines:(NSSet *)values;

@end
