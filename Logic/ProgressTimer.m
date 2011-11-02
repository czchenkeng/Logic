//
//  ProgressTimer.m
//  Logic
//
//  Created by Pavel Krusek on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProgressTimer.h"

@interface ProgressTimer (PrivateMethods)
- (void) buildTimer;
- (void) moveClock:(CCArray *)arr;
- (void) formatClock:(int)value where:(int)where;
@end

@implementation ProgressTimer
@synthesize gameTime;

- (id) init {
    self = [super init];
    if (self != nil) {
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
        gameTime = 0;
        clockArray = [[CCArray alloc] init];
        [self buildTimer];
    }
    return self;
}

- (void) setupClock:(int)time {
    first = 0;
    tenSec = 0;
    tenMins = 0;
    myTime = 0;
    totalTime = time;
    secTime = 1.00/18;
    
    if (time > 0) {
        NSString *startTime = [NSString stringWithFormat:@"%02d%02d",(int)totalTime/60, (int)totalTime%60];
        for (int i = 0; i < startTime.length; i++) {
            [self formatClock:[[NSString stringWithFormat:@"%c", [startTime characterAtIndex:i]] intValue] where:i];
        }
    }
    [self schedule:@selector(update:) interval:0];
}

- (void) formatClock:(int)value where:(int)where {
    int i = 0;
    int coef = [[clockArray objectAtIndex:where] count] - value;
    for (CCSprite *sprite in [clockArray objectAtIndex:where]){
        if (i < value) {
            sprite.position = ccp(sprite.position.x, (coef + i)*ADJUST_2(-18));
        } else {
            sprite.position = ccp(sprite.position.x, (value - i)*ADJUST_2(18)); 
        }
        i++;
    }
}

- (void) buildTimer {
    seconds = [CCLayer node];
    seconds.position = ccp(ADJUST_2(30.50), 0);
    [self addChild:seconds];
    
    secondsArray = [[CCArray alloc] init];    
    CCSprite *secs;
    for (int i=0; i < 10; i++) {
        secs = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%i.png", i]];
        secs.anchorPoint = ccp(0,0);
        secs.position = ccp(0, i*ADJUST_2(-18));
        [seconds addChild:secs];
        [secondsArray addObject:secs];
    }
    
    tenSeconds = [CCLayer node];
    tenSeconds.position = ccp(ADJUST_2(21.50), 0);
    [self addChild:tenSeconds];
    tenSecondsArray = [[CCArray alloc] init];    
    CCSprite *tenSecs;
    for (int i=0; i < 6; i++) {
        tenSecs = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%i.png", i]];
        tenSecs.anchorPoint = ccp(0,0);
        tenSecs.position = ccp(0, i*ADJUST_2(-18));
        [tenSeconds addChild:tenSecs];
        [tenSecondsArray addObject:tenSecs];
    }
    
    minutes = [CCLayer node];
    minutes.position = ccp(ADJUST_2(9), 0);
    [self addChild:minutes];
    minutesArray = [[CCArray alloc] init];
    CCSprite *minute;
    for (int i=0; i < 10; i++) {
        minute = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%i.png", i]];
        minute.anchorPoint = ccp(0,0);
        minute.position = ccp(0, i*ADJUST_2(-18));
        [minutes addChild:minute];
        [minutesArray addObject:minute];
    }
    
    
    hours = [CCLayer node];
    [self addChild:hours];
    hoursArray = [[CCArray alloc] init];
    CCSprite *hour;
    for (int i=0; i < 6; i++) {
        hour = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%i.png", i]];
        hour.anchorPoint = ccp(0,0);
        hour.position = ccp(0, i*ADJUST_2(-18));
        [hours addChild:hour];
        [hoursArray addObject:hour];
    }
    
    CCSprite *colon = [CCSprite spriteWithSpriteFrameName:@"colon.png"];
    colon.anchorPoint = ccp(0,0);
    colon.position = ccp(ADJUST_2(18), 0);
    [self addChild:colon];
    
    [clockArray addObject:hoursArray];
    [clockArray addObject:minutesArray];
    [clockArray addObject:tenSecondsArray];
    [clockArray addObject:secondsArray];
}

- (void) moveClock:(CCArray *)arr {
    first ++;
    //CCLOG(@"kolikrat %i", first);
    for (CCSprite *sprite in arr) {
        sprite.position = ccp(sprite.position.x, sprite.position.y + ADJUST_2(1));
        if (sprite.position.y > ADJUST_2(18.00)) {
            sprite.position = ccp(0, 9 * ADJUST_2(-18.00));
        }
    }
}

- (void) moveTime:(CCArray *)arr {
    for (CCSprite *sprite in arr) {
        CCMoveTo *timeMove = [CCMoveTo actionWithDuration:1.00 position:ccp(0, sprite.position.y + ADJUST_2(18))];
        CCArray *param = [[CCArray alloc] initWithCapacity:2];
        [param addObject:sprite];
        [param addObject:[NSNumber numberWithInt:arr.count]];
        CCSequence *timeSeq = [CCSequence actions:timeMove, [CCCallFuncND actionWithTarget:self selector:@selector(timeMoveEnded:data:) data:param], nil];
        [sprite runAction:timeSeq];
    }
}

- (void) timeMoveEnded:(id)sender data:(CCArray *)param {
    CCSprite *sprite = [param objectAtIndex:0];
    int jump = [[param objectAtIndex:1] intValue];
    if (sprite.position.y > 18.00f) {
        sprite.position = ccp(0, (jump - 2)*ADJUST_2(-18));
    }
}

- (int) stopTimer {
    [self unschedule:@selector(update:)];
    return myTime;
}

- (void) resumeTimer {
    [self schedule:@selector(update:) interval:0];
}

- (void) update:(ccTime)dt {
    totalTime += dt;
    currentTime = (int)totalTime;
    gameTime = (int)totalTime;
    if (totalTime - currentTime > secTime) {
        secTime += 1.00/18;
        [self moveClock:secondsArray];
    }
	if (myTime < currentTime)
	{
        secTime = 1.00/18;
        first = 0;
        myTime = currentTime;
        sec = myTime % 10;
        min = myTime % 60;
        
        CCLOG(@"game timer %@",  [NSString stringWithFormat:@"%02d:%02d", myTime/60, myTime%60]);
        [self moveClock:secondsArray];
                
        if (sec == 9) {
            tenSec ++;
            if (tenSec == 6) {
                tenSec = 0;
            } 
            [self moveTime:tenSecondsArray];
        }
        
//        if (min == 0) {
//            PLAYSOUNDEFFECT(GONG);
//        }
        
        if (min == 59) {
            PLAYSOUNDEFFECT(GONG);
            [self moveTime:minutesArray]; 
        }
    }
}

- (void) dealloc {
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    [secondsArray release];
    [tenSecondsArray release];
    [minutesArray release];
    [hoursArray release];
    [clockArray release];
    secondsArray = nil;
    tenSecondsArray = nil;
    minutesArray = nil;
    hoursArray = nil;
    clockArray = nil;
    [super dealloc];
}

@end
