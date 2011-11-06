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
    
    int min;
}

@property (readonly) int gameTime;

- (void) setupClock:(int)time;
- (int) stopTimer;
- (void) resumeTimer;

@end
