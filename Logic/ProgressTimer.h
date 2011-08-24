//
//  ProgressTimer.h
//  Logic
//
//  Created by Pavel Krusek on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProgressTimer : CCSprite {
	ccTime totalTime;
	int myTime;
	int currentTime;
    float secTime;
    int gameTime;
    
    CCLayer *seconds;
    CCArray *secondsArray;
    int sec;
    
    
    CCLayer *tenSeconds;
    CCArray *tenSecondsArray;
    int tenSec;
    
    
    CCLayer *minutes;
    CCArray *minutesArray;
    int min;
    
    CCLayer *hours;
    CCArray *hoursArray;
    int tenMins;
    
    CCArray *clockArray;
    
    int first;
    
}

@property (readonly) int gameTime;

- (int) stopTimer;
- (void) setupClock:(int)time;

@end
