//
//  ScoreCalc.h
//  Logic
//
//  Created by Pavel Krusek on 8/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>


@interface ScoreCalc : NSObject {
    int colorsCount;
    int pinsCount;
    int totalTurns;
    int points;
    
    NSArray *hiddenPattern;
    NSMutableArray *patterns;
    
    dispatch_queue_t backgroundQueue;
}

@property (nonatomic, copy) NSArray *hiddenPattern;

+ (id) scoreWithColors:(int)c pins:(int)p;

- (int) calculateScoreWithRow:(int)row andTurn:(NSArray *)turn;

@end
