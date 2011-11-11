//
//  MainGameLayer.h
//  Logic
//
//  Created by Pavel Krusek on 11/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HowToLayer.h"

#import "GADBannerView.h"
#import "RootViewController.h"
#import "CDXPropertyModifierAction.h"

@interface MainGameLayer : CCLayerColor {
    int counter;
    int flag;
    int flag2;
    BOOL lightOn;
    
    BOOL gameInProgress;
    BOOL isCareer;
    
    BOOL isFromLevel;
    
    CCParticleSystem *system;
    
    CCSprite *light;
    CCSprite *lightOff;
    CCSprite *leftGib;
    CCSprite *rightGib;
    CCSprite *rightSingleGib;
    CCSprite *background;
    CCSprite *doors;
    CCSprite *logoShadow;
    CCSprite *logo;
    
    CCMenu *topMenu;
    CCMenu *toggleMenu;
    CCMenu *singleMenu;
    CCMenu *careerMenu;
    CCMenu *continueMenu;
    CCMenu *newGameMenu;
    CCMenu *gameMenu;
    CCMenu *quitMenu;
    
    CCMenuItem *infoOff;
    CCMenuItem *infoOn;
    CCMenuItemToggle *toggleItem;
    
    HowToLayer *howToLayer;
    
    GADBannerView *bannerView;
    RootViewController *controller;
}

@end
