//
//  ScoreCalc.h
//  Logic
//
//  Created by Pavel Krusek on 8/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>
#import "GameManager.h"


@interface ScoreCalc : NSObject {
    int colorsCount;
    int pinsCount;
    int totalTurns;
    int points;
    int endBonus;
    
    NSArray *hiddenPattern;
    NSMutableArray *patterns;
        
    dispatch_queue_t backgroundQueue;
    
    BOOL done;
    NSMutableArray *saveData;
}

@property (nonatomic, copy) NSArray *hiddenPattern;
@property (readonly) int endBonus;

+ (id) scoreWithColors:(int)c pins:(int)p row:(int)r;

- (int) calculateScoreWithRow:(int)row andTurn:(NSArray *)turn andTime:(int)roundTime;
- (int) getBonus;
- (void) previousData;

@end
