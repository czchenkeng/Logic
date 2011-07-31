//
//  Figure.m
//  Logic
//
//  Created by Pavel Krusek on 5/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Figure.h"


@implementation Figure

@synthesize currentFigure, originalPosition, tempPosition, movePosition, place, oldPlace, isActive, isCalculated, isOnActiveRow, startTime, endTime;

- (Figure *) initWithFigureType:(FigureTypes)figureID {
    
    currentFigure = figureID;
    place = -1;
    oldPlace = -1;
    isActive = YES;
    isCalculated = NO;
    isOnActiveRow = NO;
    
    NSString *imageFile;
    switch (figureID) {
        case kYellow: 
            imageFile = @"pinchYellow.png";
            break;
        case kOrange:
            imageFile = @"pinchOrange.png";
            break;
        case kPink:
            imageFile = @"pinchPink.png";
            break;
        case kRed:
            imageFile = @"pinchRed.png";
            break;
        case kPurple:
            imageFile = @"pinchPurple.png";
            break;
        case kBlue:
            imageFile = @"pinchBlue.png";
            break;
        case kGreen:
            imageFile = @"pinchGreen.png";
            break;
        case kWhite:
            imageFile = @"pinchWhite.png";
            break;
        default:
            CCLOG(@"Unknown ID, cannot create figure");
            return nil;
            break;
    }
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Level.plist"];
    
    
    self = [super initWithSpriteFrameName:imageFile];
    [imageFile release];
    
    return self;
}

- (void) destroy {
    [self removeFromParentAndCleanup:YES];
}

- (void) dealloc {
    CCLOG(@"Sprite dealloc");
    //self = nil;
    [super dealloc];
}

@end