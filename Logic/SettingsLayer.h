//
//  SettingsLayer.h
//  Logic
//
//  Created by Pavel Krusek on 6/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCSlider.h"
#import "PressMenu.h"

@interface SettingsLayer : CCLayer <CCSliderControlDelegate> {
    CCArray *difficulty;
    CCArray *joysticks;
    
    CCSlider *musicSlider;
    CCSlider *soundSlider;
    
    CCSprite *easy;
    CCSprite *normal;
    CCSprite *hard;
    
    CCSprite *joyStick;
    CCSprite *selJoystick;
    
    CCMenuItem *easyItem;
    CCMenuItem *normalItem;
    CCMenuItem *hardItem;
    
    CGPoint touchOrigin;
    CGPoint touchStop;
    
    float previousMusic;
    float previousSound;
}

@end
