//
//  Thunderbolt.h
//  Logic
//
//  Created by Apple on 10/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Thunderbolt : CCNode {
    NSMutableArray *thunderboltFrames;
    CCSpriteBatchNode *thunderboltNode;
    float distance;
    
    CCParticleSystem *startVyronSystem;
    CCParticleSystem *endVyronSystem;
}

- (void) initWithStartPoint:(CGPoint) startPoint andEndPoint:(CGPoint) endPoint andType:(NSString *)type andScale:(BOOL)sc;

@end
