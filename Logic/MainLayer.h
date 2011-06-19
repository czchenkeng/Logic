//
//  MainLayer.h
//  Logic
//
//  Created by Pavel Krusek on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utils.h"

typedef enum {
    kButtonInfo,
    kButtonSettings,
    kButtonSinglePlay,
    kButtonCareerPlay
} buttonTypes;


@interface MainLayer : CCLayerColor {
    int counter;
    int flag;
    int flag2;
    BOOL lightOn;
    CCSprite *light;
    CCSprite *lightOff;
}

@end
