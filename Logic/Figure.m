//
//  Figure.m
//  Logic
//
//  Created by Pavel Krusek on 5/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Figure.h"


@implementation Figure

@synthesize currentFigure, originalPosition;

- (Figure *) initWithFigureType:(FigureTypes)figureID {    
    //self = [super initWithFile:imageFile];
    //self = [super init];
    
    currentFigure = figureID;
    
    //if (self) {
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
        
        [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"LevelPinchHd.plist"];
        
        //self = [CCSprite spriteWithSpriteFrameName:imageFile];
        
        self = [super initWithSpriteFrameName:imageFile];
        [imageFile release];
    //}
    
    return self;
}

- (void) dealloc {
    [super dealloc];
}

@end