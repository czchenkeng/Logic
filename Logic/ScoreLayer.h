//
//  ScoreLayer.h
//  Logic
//
//  Created by Pavel Krusek on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"


@interface ScoreLayer : CCLayer {
    FMDatabase *db;
    
    CCArray *difficulty;
    
    CCSprite *easy;
    CCSprite *normal;
    CCSprite *hard;
    
    CCSprite *joyStick;
    CCSprite *selJoystick;
    
    CCMenuItem *easyItem;
    CCMenuItem *normalItem;
    CCMenuItem *hardItem;
    
    CGPoint touchOrigin;
    CGPoint touchStop;
}

@end
