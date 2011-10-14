//
//  Figure.m
//  Logic
//
//  Created by Pavel Krusek on 5/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Figure.h"


@implementation Figure

@synthesize currentFigure, originalPosition, tempPosition, movePosition, place, oldPlace, fid, isActive, isCalculated, isOnActiveRow;//, startTime, endTime;

- (Figure *) initWithFigureType:(FigureTypes)figureID {
    
    currentFigure = figureID;
    place = -1;
    oldPlace = -1;
    isActive = YES;
    isCalculated = NO;
    isOnActiveRow = NO;
    
    NSString *imageFile;
    switch (figureID) {
        case kYellow://0 
            imageFile = @"pinchYellow.png";
            break;
        case kOrange://1
            imageFile = @"pinchOrange.png";
            break;
        case kPink://2
            imageFile = @"pinchPink.png";
            break;
        case kRed://3
            imageFile = @"pinchRed.png";
            break;
        case kPurple://4
            imageFile = @"pinchPurple.png";
            break;
        case kBlue://5
            imageFile = @"pinchBlue.png";
            break;
        case kGreen://6
            imageFile = @"pinchGreen.png";
            break;
        case kWhite://7
            imageFile = @"pinchWhite.png";
            break;
        default:
            CCLOG(@"Unknown ID, cannot create figure");
            return nil;
            break;
    }
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kLevelLevelTexture];
        
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