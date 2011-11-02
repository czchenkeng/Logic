//
//  ProgTimer.h
//  Logic
//
//  Created by Pavel Krusek on 11/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProgTimer : CCSprite {
    ccTime totalTime;
	int myTime;
	int currentTime;
    
    CCLayer *secLayer;
    CCLayer *tenSecLayer;
    CCLayer *minLayer;
    CCLayer *tenMinLayer;
    
    int tenSec;
    int minute;
    int tenMin;
    
    BOOL firstRun;
    BOOL firstRun1;
    BOOL firstRun2;
    
    int vsec;
    int vtenSec;
    int vmin;
    int vtenMin;
}

@property (readonly) int gameTime;

- (void) setupClock:(int)time;
- (int) stopTimer;
- (void) resumeTimer;

@end
