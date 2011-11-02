//
//  ProgTimer.m
//  Logic
//
//  Created by Pavel Krusek on 11/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProgTimer.h"

@interface ProgTimer (PrivateMethods)
- (void) secondDone:(int)sec;
- (void) tenSecondDone:(int)sec;
- (void) minuteDone:(int)sec;
- (void) tenMinuteDone:(int)sec;
@end


@implementation ProgTimer

@synthesize gameTime;

- (id) init {
    self = [super init];
    if (self != nil) {
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
        gameTime = 0;
//        firstRun = YES;
//        firstRun1 = YES;
//        firstRun2 = YES;
//        [self secondDone:0];
//        [self minuteDone:0];
//        [self tenMinuteDone:0];
        CCSprite *colon = [CCSprite spriteWithSpriteFrameName:@"colon.png"];
        colon.anchorPoint = ccp(0,0);
        colon.position = ccp(ADJUST_2(18), 0);
        [self addChild:colon];
    }
    return self;
}

- (void) setupClock:(int)time {
    myTime = 0;
    totalTime = time;
    
    firstRun = YES;
    firstRun1 = YES;
    firstRun2 = YES;
    
    CCLOG(@"\n\n\n\n\nJAKY JE TIME %i\n\n\n\n\n", time/60);
    
    
    
    [self secondDone:0];
    [self minuteDone:0];
    [self tenMinuteDone:0];
    
    [self schedule:@selector(update:) interval:0];
}

- (int) stopTimer {
    [self unschedule:@selector(update:)];
    return myTime;
}

- (void) resumeTimer {
    [self schedule:@selector(update:) interval:0];
}

- (void) secondDone:(int)sec {
//    CCLOG(@"second done %i", sec);
//    CCLOG(@"second above %i", sec-1);
//    CCLOG(@"second below %i", sec);
//    CCLOG(@"=========================================");
    
    [secLayer removeFromParentAndCleanup:YES];
    secLayer = [CCLayer node];
    secLayer.position = ccp(ADJUST_2(30.50), 0);
    [self addChild:secLayer];
    int valueAbove;
    int valueBelow;
    if (sec == 0) {
        valueAbove = 9;
        valueBelow = 0;
        [self tenSecondDone:tenSec];
    }else{
        valueAbove = sec - 1;
        valueBelow = sec;
    }
    //CCLOG(@"second done %i", sec);
//    CCLOG(@"second above %i", valueAbove);
//    CCLOG(@"second below %i", valueBelow);
//    CCLOG(@"=========================================");
    CCSprite *above = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%i.png", valueAbove]];
    CCSprite *below = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%i.png", valueBelow]];
    below.position = ccp(0, ADJUST_2(-18));
    above.anchorPoint = ccp(0, 0);
    below.anchorPoint = ccp(0, 0);
    [secLayer addChild:above];
    [secLayer addChild:below];
    id moveSec = [CCMoveTo actionWithDuration:1.00 position:ccp(secLayer.position.x, secLayer.position.y + ADJUST_2(18))];
    [secLayer runAction:moveSec];
}

- (void) tenSecondDone:(int)sec {
    [tenSecLayer removeFromParentAndCleanup:YES];
    tenSecLayer = [CCLayer node];
    tenSecLayer.position = ccp(ADJUST_2(21.50), 0);
    [self addChild:tenSecLayer];
    int valueAbove;
    int valueBelow;
    if(sec == 0){
        sec = 1;
    }
    if (sec == 6) {
        valueAbove = 5;
        valueBelow = 0;
        tenSec = 1;
        [self minuteDone:minute];
    }else{
        valueAbove = sec - 1;
        valueBelow = sec;
        tenSec++;
    }
//    CCLOG(@"ten second above %i", valueAbove);
//    CCLOG(@"ten second below %i", valueBelow);
//    CCLOG(@"=========================================");
    CCSprite *above = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%i.png", valueAbove]];
    CCSprite *below = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%i.png", valueBelow]];
    below.position = ccp(0, ADJUST_2(-18));
    above.anchorPoint = ccp(0, 0);
    below.anchorPoint = ccp(0, 0);
    [tenSecLayer addChild:above];
    [tenSecLayer addChild:below];
    if (!firstRun) {
        id moveSec = [CCMoveTo actionWithDuration:1.00 position:ccp(tenSecLayer.position.x, tenSecLayer.position.y + ADJUST_2(18))];
        [tenSecLayer runAction:moveSec];
    }
    firstRun = NO;
}

- (void) minuteDone:(int)sec {
    [minLayer removeFromParentAndCleanup:YES];
    minLayer = [CCLayer node];
    minLayer.position = ccp(ADJUST_2(9), 0);
    [self addChild:minLayer];
    int valueAbove;
    int valueBelow;
    if (sec == 0) {
        valueAbove = 9;
        valueBelow = 0;
        minute = 1;
        //[self tenSecondDone:tenSec];
    }else{
        valueAbove = sec - 1;
        valueBelow = sec;
        minute++;
    }
//    CCLOG(@"minute above %i", valueAbove);
//    CCLOG(@"minute below %i", valueBelow);
//    CCLOG(@"=========================================");
    CCSprite *above = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%i.png", valueAbove]];
    CCSprite *below = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%i.png", valueBelow]];
    below.position = ccp(0, ADJUST_2(-18));
    above.anchorPoint = ccp(0, 0);
    below.anchorPoint = ccp(0, 0);
    [minLayer addChild:above];
    [minLayer addChild:below];
    if (!firstRun) {
        id moveSec = [CCMoveTo actionWithDuration:1.00 position:ccp(minLayer.position.x, minLayer.position.y + ADJUST_2(18))];
        [minLayer runAction:moveSec];
    }
    //firstRun1 = NO;
}


- (void) tenMinuteDone:(int)sec {
    [tenMinLayer removeFromParentAndCleanup:YES];
    tenMinLayer = [CCLayer node];
    tenMinLayer.position = ccp(0, 0);
    [self addChild:tenMinLayer];
    int valueAbove;
    int valueBelow;
    if(sec == 0){
        sec = 1;
    }
    if (sec == 6) {
        valueAbove = 5;
        valueBelow = 0;
        tenMin = 1;
        [self minuteDone:minute];
    }else{
        valueAbove = sec - 1;
        valueBelow = sec;
        tenMin++;
    }
//    CCLOG(@"ten minutes above %i", valueAbove);
//    CCLOG(@"ten minutes below %i", valueBelow);
//    CCLOG(@"=========================================");
    CCSprite *above = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%i.png", valueAbove]];
    CCSprite *below = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%i.png", valueBelow]];
    below.position = ccp(0, ADJUST_2(-18));
    above.anchorPoint = ccp(0, 0);
    below.anchorPoint = ccp(0, 0);
    [tenMinLayer addChild:above];
    [tenMinLayer addChild:below];
    if (!firstRun2) {
        id moveSec = [CCMoveTo actionWithDuration:1.00 position:ccp(tenMinLayer.position.x, tenMinLayer.position.y + ADJUST_2(18))];
        [tenMinLayer runAction:moveSec];
    }
    firstRun2 = NO;
}



- (void) update:(ccTime)dt {
    totalTime += dt;
    currentTime = (int)totalTime;
    gameTime = (int)totalTime;
	if (myTime < currentTime)
	{
        myTime = currentTime;
        //sec = myTime % 10;
        //min = myTime % 60;
        
        
        [self secondDone:(myTime % 10)];
        //CCLOG(@"game timer %@",  [NSString stringWithFormat:@"%02d:%02d", myTime/60, myTime%60]);
        //CCLOG(@"ten sec %d", myTime/10);
        //CCLOG(@"========================================");
    }
}

- (void) dealloc {
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    [super dealloc];
}

@end
