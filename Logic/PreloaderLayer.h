//
//  PreloaderLayer.h
//  Logic
//
//  Created by Pavel Krusek on 8/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameManager.h"
#import <MediaPlayer/MediaPlayer.h>

@interface PreloaderLayer : CCLayerColor {
    CCSprite *factory;
    CCSprite *zaklad_mraky;
    CCSprite *blesk1;
    CCSprite *blesk2;
    CCSprite *blesk3;
    CCSprite *blesk4;
    CCSprite *hrany;
    CCSprite *ciselnik;
    CCSprite *budik;
    CCSprite *rucicka;
    
    CCLayer *composition;
    
    CGPoint controlPoint1;
	CGPoint controlPoint2;
	CGPoint endPosition;
    
    ccBezierConfig bezier;
    
    //MPMoviePlayerViewController *mp;
}

@end
