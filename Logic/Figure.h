//
//  Figure.h
//  Logic
//
//  Created by Pavel Krusek on 5/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"


@interface Figure : CCSprite {
    FigureTypes currentFigure;
    CGPoint originalPosition;
    CGPoint tempPosition;
    CGPoint movePosition;
    int place;
    int oldPlace;
    int fid;
    BOOL isActive;
    BOOL isCalculated;
    BOOL isOnActiveRow;
//    NSDate *startTime;
//    NSDate *endTime;
}

- (Figure *) initWithFigureType:(FigureTypes)figureID;

@property FigureTypes currentFigure;
@property CGPoint originalPosition;
@property CGPoint tempPosition;
@property CGPoint movePosition;
@property int place;
@property int fid;
@property int oldPlace;
@property BOOL isActive;
@property BOOL isCalculated;
@property BOOL isOnActiveRow;
//@property (nonatomic, copy) NSDate *startTime;
//@property (nonatomic, copy) NSDate *endTime;

- (void) destroy;

@end
