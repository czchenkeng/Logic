//
//  Figure.m
//  Logic
//
//  Created by Pavel Krusek on 5/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Figure.h"


@implementation Figure

@synthesize imageSprite;

- (Figure *) initWithFigureType:(FigureTypes)figureID {    
    //self = [super initWithFile:imageFile];
    self = [super init];
    CCLOG(@"FIGURE ID %i", figureID);
    
    if (self) {
        NSString *imageFile;
        switch (figureID) {
            case kYellow: 
                imageFile = @"figureYellow.png";
                break;
            case kOrange:
                imageFile = @"figureOrange.png";
                break;
            case kPink:
                imageFile = @"figurePink.png";
                break;
            case kRed:
                imageFile = @"figureRed.png";
                break;
            case kPurple:
                imageFile = @"figurePurple.png";
                break;
            case kBlue:
                imageFile = @"figureBlue.png";
                break;
            case kGreen:
                imageFile = @"figureGreen.png";
                break;
            case kWhite:
                imageFile = @"figureWhite.png";
                break;
            default:
                CCLOG(@"Unknown ID, cannot create figure");
                return nil;
                break;
        }
        
        [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"gameAssets-hd.plist"];
        
        self = [CCSprite spriteWithSpriteFrameName:imageFile];
        
        //imageSprite = [CCSprite spriteWithSpriteFrameName:imageFile];
        
        //[self addChild:imageSprite z:1];
        
        [imageFile release];
    }
    
    return self;
}

- (void) dealloc {
    [super dealloc];
}

@end