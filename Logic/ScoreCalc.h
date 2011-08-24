//
//  ScoreCalc.h
//  Logic
//
//  Created by Pavel Krusek on 8/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Guess.h"

@interface ScoreCalc : NSObject {
    int colorsCount;
    int pinsCount;
    int totalTurns;
    int points;
    
    CCArray *hiddenPattern;
    CCArray *patterns;
}

@property (nonatomic, copy) CCArray *hiddenPattern;

+ (id) scoreWithColors:(int)c pins:(int)p;

- (int) calculateScoreWithRow:(int)row andTurn:(CCArray *)turn;

@end
