//
//  Thunderbolt.m
//  Logic
//
//  Created by Apple on 10/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Thunderbolt.h"
#import "Utils.h"


@implementation Thunderbolt

- (void) initWithStartPoint:(CGPoint) startPoint andEndPoint:(CGPoint) endPoint andType:(NSString *)type andScale:(BOOL)sc {
    thunderboltNode = [CCSpriteBatchNode batchNodeWithFile:@"Lightning.pvr.ccz"];
    thunderboltFrames = [[NSMutableArray alloc] initWithCapacity:15];
    
    distance = ccpDistance(startPoint, endPoint);
    
//    NSString *type;    
//    if (distance > 150)
//        type = @"long_";
//    else
//        type = @"small_";
    
    int random = [Utils randomNumberBetween:0 andMax:15];
    for(int i = 1 + random; i <= 15 + random; ++i) {
        [thunderboltFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@%d.png", type, i > 15 ? i - 15 : i]]];
    }
    CCAnimation *tAnimation = [CCAnimation animationWithFrames:thunderboltFrames delay:0.04f];
    CCAnimate *tAnimate = [CCAnimate actionWithAnimation:tAnimation restoreOriginalFrame:NO];
    CCRepeat *tRepeat = [CCRepeat actionWithAction:tAnimate times:2];
    id tSeq = [CCSequence actions:tRepeat,
               [CCCallFunc actionWithTarget:self selector:@selector(tAnimEnded)],
               nil];
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@%d.png", type, 1]];
    sprite.anchorPoint = ccp(0.5, 1);
    
    if (sc)
        sprite.scale = distance / sprite.contentSize.height;
    else 
        sprite.scaleY = distance / sprite.contentSize.height;
    
    float angle = ccpToAngle(ccpSub(startPoint, endPoint));    
    angle = CC_RADIANS_TO_DEGREES(angle);
    angle -= 90;
    angle *= -1;
    sprite.rotation = angle;
    
    [thunderboltNode addChild:sprite];
    [sprite runAction:tSeq];
    [self addChild:thunderboltNode];
    PLAYSOUNDEFFECT(FLASH1);
    
    startVyronSystem = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:kVyronParticle];
    startVyronSystem.autoRemoveOnFinish = YES;
    startVyronSystem.position = ccp(0, 0);
    [self addChild:startVyronSystem z:2];

    endVyronSystem = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:kVyronParticle];
    endVyronSystem.autoRemoveOnFinish = YES;
    endVyronSystem.position = ccp(endPoint.x - startPoint.x, endPoint.y - startPoint.y);
    [self addChild:endVyronSystem z:2];
    
}

- (void) tAnimEnded {
    [self removeFromParentAndCleanup:YES];
}

- (void) dealloc {
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    [thunderboltFrames release];
    thunderboltFrames = nil;
    [super dealloc];
}

@end