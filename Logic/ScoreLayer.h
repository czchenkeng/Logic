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
#import "Score.h"
#import "CCUIViewWrapper.h"
#import "ScoresListViewController.h"


@interface ScoreLayer : CCLayer {
    FMDatabase *db;
    FMResultSet *rs;
    NSString *DBPath;
    
    NSString *databasePath;
    
    ScoresListViewController *controller;
    
    NSMutableArray *scores;
    
    CCArray *difficulty;
    CCArray *joysticks;
    
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

@property (nonatomic, retain, readwrite) NSMutableArray *scores;

@end
