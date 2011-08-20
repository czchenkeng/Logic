//
//  ProgressTimer.m
//  Logic
//
//  Created by Pavel Krusek on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProgressTimer.h"


@implementation ProgressTimer
@synthesize gameTime;


- (void) prepareAssets {
    seconds = [CCLayer node];
    seconds.position = ccp(30.50, 0);
    [self addChild:seconds];
    
    secondsArray = [[CCArray alloc] init];    
    CCSprite *secs;
    for (int i=0; i < 10; i++) {
        secs = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%i.png", i]];
        secs.anchorPoint = ccp(0,0);
        secs.position = ccp(0, i*-18);
        [seconds addChild:secs];
        [secondsArray addObject:secs];
    }
    
    tenSeconds = [CCLayer node];
    tenSeconds.position = ccp(21.50, 0);
    [self addChild:tenSeconds];
    tenSecondsArray = [[CCArray alloc] init];    
    CCSprite *tenSecs;
    for (int i=0; i < 6; i++) {
        tenSecs = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%i.png", i]];
        tenSecs.anchorPoint = ccp(0,0);
        tenSecs.position = ccp(0, i*-18);
        [tenSeconds addChild:tenSecs];
        [tenSecondsArray addObject:tenSecs];
    }
    
    minutes = [CCLayer node];
    minutes.position = ccp(9, 0);
    [self addChild:minutes];
    minutesArray = [[CCArray alloc] init];
    CCSprite *minute;
    for (int i=0; i < 10; i++) {
        minute = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%i.png", i]];
        minute.anchorPoint = ccp(0,0);
        minute.position = ccp(0, i*-18);
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
        hour.position = ccp(0, i*-18);
        [hours addChild:hour];
        [hoursArray addObject:hour];
    }
    
    CCSprite *colon = [CCSprite spriteWithSpriteFrameName:@"colon.png"];
    colon.anchorPoint = ccp(0,0);
    colon.position = ccp(18, 0);
    [self addChild:colon];
    
}


- (void) moveClock:(CCArray *)arr {
    for (CCSprite *sprite in arr) {
        [self stopAllActions];
        CCMoveTo *secondsMove = [CCMoveTo actionWithDuration:0.90 position:ccp(0, sprite.position.y + 18)];
        CCSequence *secondsSeq = [CCSequence actions:secondsMove, [CCCallFuncND actionWithTarget:self selector:@selector(timeMoveEnded:data:) data:sprite], nil];
        //CCSequence *secondsSeq = [CCSequence actions:secondsMove, nil];
        [sprite runAction:secondsSeq];
    }
}

- (void) timeMoveEnded:(id)sender data:(CCSprite *)sprite {
    if (sprite.position.y > 1.00f) {
        sprite.position = ccp(0, 9*-18);
    }
}

- (void) endAnimation:(CCArray *)arr stop:(int)st flag:(int)fl {
    int indx;
    if (fl == 0) {
        indx = st;
    } else {
        indx = fl - 1;
    }
    CCSprite *spriteToMove = [arr objectAtIndex:indx];
    [spriteToMove setPosition:ccp(0, -st*18)];
}

- (id) init {
    self = [super init];
    if (self != nil) {
        [self prepareAssets];
        first = 0;
        tenSec = 0;
        myTime = 0;
        totalTime = 0;
        
        [self moveClock:secondsArray];
        
        [self schedule:@selector(update:) interval:1.00];
        //[self schedule:@selector(update:)];
    }
    return self;
}

- (int) stopTimer {
    [self unschedule:@selector(update:)];
    return myTime;
}


- (void) update:(ccTime)dt{
    
    totalTime += dt;
    currentTime = (int)totalTime;
    gameTime = (int)totalTime;
	if (myTime < currentTime)
	{
		myTime = currentTime;
        //CCLOG(@"game timer %@",  [NSString stringWithFormat:@"%02d:%02d", myTime/60, myTime%60]);
        //CCLOG(@"my time %i",  myTime);
        sec = myTime % 10;
        min = myTime % 60;
        //CCLOG(@"timer %i",  seconds < 10 ? seconds : abs(10 - seconds));
        //CCLOG(@"SECONDS %i",  sec);
        //CCLOG(@"mins %i",  myTime % 60);
        //[self endAnimation:secondsArray stop:9 flag:sec];
        [self moveClock:secondsArray];
        
//        if (sec == 9) {
//            tenSec ++;
//            if (tenSec == 6) {
//                tenSec = 0;
//            }
//            //if (first > 60)
//            [self endAnimation:tenSecondsArray stop:5 flag:tenSec]; 
//            [self moveClock:tenSecondsArray];
//        }
//        
//        if (min == 59) {
//           [self endAnimation:minutesArray stop:9 flag:sec]; 
//           [self moveClock:minutesArray]; 
//        }
        
        first ++;
    }
    
}

@end
