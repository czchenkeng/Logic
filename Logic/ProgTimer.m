//
//  ProgTimer.m
//  Logic
//
//  Created by Pavel Krusek on 11/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProgTimer.h"

@interface ProgTimer (PrivateMethods)
- (void) secondDone:(int)sec animation:(BOOL)anim;
- (void) tenSecondDone:(int)sec animation:(BOOL)anim;
- (void) minuteDone:(int)sec animation:(BOOL)anim;
- (void) tenMinuteDone:(int)sec animation:(BOOL)anim;
- (void) setTime:(NSString *)str;
@end


@implementation ProgTimer

@synthesize gameTime;

- (id) init {
    self = [super init];
    if (self != nil) {
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
        gameTime = 0;

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
    
    CCLOG(@"\n\n\n\ntime\n\n\n\n %@",  [NSString stringWithFormat:@"%02d%02d", time/60, time%60]);
    
    if (time == 0) {
        [self secondDone:1 animation:NO];
        [self tenSecondDone:1 animation:NO];
        [self minuteDone:1 animation:NO];
        [self tenMinuteDone:1 animation:NO];
    }else{
        [self setTime:[NSString stringWithFormat:@"%02d%02d", time/60, time%60]];
    }
    

    
    [self schedule:@selector(update:) interval:0];
}

- (void) setTime:(NSString *)str {
    NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[str length]];
    for (int i=0; i < [str length]; i++) {
        NSNumber *ichar;
        ichar  = [NSNumber numberWithInt:[[NSString stringWithFormat:@"%c", [str characterAtIndex:i]] intValue]];
        [characters addObject:ichar];
    }
    //CCLOG(@"time pole %@", characters);
    [self secondDone:1 animation:NO];
    [self tenSecondDone:[[characters objectAtIndex:2] intValue]+1 animation:NO];
    [self minuteDone:[[characters objectAtIndex:1] intValue]+1 animation:NO];
    [self tenMinuteDone:[[characters objectAtIndex:0] intValue]+1 animation:NO];
    tenSec = [[characters objectAtIndex:2] intValue]+1;
    minute = [[characters objectAtIndex:1] intValue]+1;
    tenMin = [[characters objectAtIndex:0] intValue]+1;

}

- (int) stopTimer {
    [self unschedule:@selector(update:)];
    return myTime;
}

- (void) resumeTimer {
    [self schedule:@selector(update:) interval:0];
}

- (void) secondDone:(int)sec animation:(BOOL)anim{
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
        [self tenSecondDone:tenSec animation:YES];
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
    if (anim) {
        id moveSec = [CCMoveTo actionWithDuration:1.00 position:ccp(secLayer.position.x, secLayer.position.y + ADJUST_2(18))];
        [secLayer runAction:moveSec];
    }
    
}

- (void) tenSecondDone:(int)sec animation:(BOOL)anim{
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
        [self minuteDone:minute animation:YES];
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
    if (anim) {
        id moveSec = [CCMoveTo actionWithDuration:1.00 position:ccp(tenSecLayer.position.x, tenSecLayer.position.y + ADJUST_2(18))];
        [tenSecLayer runAction:moveSec];
    }
}

- (void) minuteDone:(int)sec animation:(BOOL)anim{
    [minLayer removeFromParentAndCleanup:YES];
    minLayer = [CCLayer node];
    minLayer.position = ccp(ADJUST_2(9), 0);
    [self addChild:minLayer];
    int valueAbove;
    int valueBelow;
    if (sec == 10)
        sec = 0;
    if (sec == 0) {
        valueAbove = 9;
        valueBelow = 0;
        minute = 1;
        [self tenMinuteDone:tenMin animation:YES];
    }else{
        valueAbove = sec - 1;
        valueBelow = sec;
        minute++;
    }
//    CCLOG(@"minute below %i", sec);
//    CCLOG(@"=========================================");
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
    if (anim) {
        id moveSec = [CCMoveTo actionWithDuration:1.00 position:ccp(minLayer.position.x, minLayer.position.y + ADJUST_2(18))];
        [minLayer runAction:moveSec];
    }
}


- (void) tenMinuteDone:(int)sec animation:(BOOL)anim {
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
    if (anim) {
        id moveSec = [CCMoveTo actionWithDuration:1.00 position:ccp(tenMinLayer.position.x, tenMinLayer.position.y + ADJUST_2(18))];
        [tenMinLayer runAction:moveSec];
    }
}



- (void) update:(ccTime)dt {
    totalTime += dt;
    currentTime = (int)totalTime;
    gameTime = (int)totalTime;
	if (myTime < currentTime)
	{
        myTime = currentTime;
        //sec = myTime % 10;
        min = myTime % 60;
        
        if (min == 59) {
            PLAYSOUNDEFFECT(GONG); 
        }
        
        [self secondDone:(myTime % 10) animation:YES];
        //CCLOG(@"game timer %@",  [NSString stringWithFormat:@"%02d:%02d", myTime/60, myTime%60]);
    }
}

- (void) dealloc {
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    [super dealloc];
}

@end
