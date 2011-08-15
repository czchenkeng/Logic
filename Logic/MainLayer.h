//
//  MainLayer.h
//  Logic
//
//  Created by Pavel Krusek on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utils.h"
#import "HowToLayer.h"

@interface MainLayer : CCLayerColor {
    int counter;
    int flag;
    int flag2;
    BOOL lightOn;
    CCSprite *light;
    CCSprite *lightOff;
    CCSprite *leftGib;
    CCSprite *rightGib;    
    CCSprite *doors;
    
    int nextScene;
    
    HowToLayer *howToLayer;
    
    CCMenu *topMenu;
}

@end
