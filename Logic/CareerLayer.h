//
//  CareerLayer.h
//  Logic
//
//  Created by Pavel Krusek on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mask.h"
#import "City.h"
#import "Wire.h"
#import "PercentNumber.h"
//#import "GameManager.h"
#import "Blackout.h"
#import "SimpleAudioEngine.h"

@class GameManager;

@interface CareerLayer : CCLayer <UIAlertViewDelegate, UIGestureRecognizerDelegate>{
    ALuint tutorSound;
    ALuint scoreSound;
    ALuint scoreSoundErase;
    
    CCLayerColor *zoomBase;
    CGPoint zbLastPos;
    
    CCLayer *tutorLayer;
    CCLayerColor *tutorBlackout;
    CCLabelBMFont *tutorTxt;
    CCSprite *tutorFinger;
    
    CCArray *citiesArray;
    CCArray *wiresArray;
    CCArray *percentLabelArray;
    CCArray *scoreLabelArray;
    
    CCSprite *infoPanel;
    CCSprite *background;
    City *selSprite;
    City *currentCity;
    CCSprite *progressBar;
    
    int buttonWidth;//zatim nefachci - mrknout se
    int buttonHeight;//zatim nefachci - mrknout se
    
    CCMenuItem *infoOff;
    CCMenuItem *infoOn;
        
    int prog;
    float total;//progress bar width
    int percent;    
    BOOL panelActive;
    
    int score;
    
    int diff;//default diff
    
    BOOL blink;
    BOOL isRetina;
    
    UIPanGestureRecognizer *panGestureRecognizer;
    UIPinchGestureRecognizer *pinchGestureRecognizer;    
    UITapGestureRecognizer *singleTapGestureRecognizer;
    


}

@end
