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
#import "GameManager.h"
#import "Lightning.h"
#import "Utils.h"

#import "GADBannerView.h"
#import "RootViewController.h"

@interface MainLayer : CCLayerColor {
    int counter;
    int flag;
    int flag2;
    BOOL lightOn;
    CCSprite *light;
    CCSprite *lightOff;
    CCSprite *leftGib;
    CCSprite *rightGib;
    CCSprite *rightSingleGib;
    CCSprite *background;
    CCSprite *doors;
    
    CCMenu *gameMenu;
    CCMenu *newGameMenu;
    CCMenu *quitMenu;
    CCMenu *continueMenu;
    CCMenu *careerMenu;
    CCMenu *singleMenu;
    CCMenu *toggleMenu;
    
    CCMenuItem *infoOff;
    CCMenuItem *infoOn;
    CCMenuItemToggle *toggleItem;
    
    BOOL isThree;
    
    //int nextScene;
    
    HowToLayer *howToLayer;
    
    CCMenu *topMenu;
    
    CCParticleSystem *system;
    
    GADBannerView *bannerView;
    RootViewController *controller;
}

@end
