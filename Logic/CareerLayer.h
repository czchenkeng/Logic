//
//  CareerLayer.h
//  Logic
//
//  Created by Pavel Krusek on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Mask.h"
#import "City.h"
#import "Wire.h"
#import "PercentNumber.h"
//#import "GameManager.h"
#import "Blackout.h"
#import "SimpleAudioEngine.h"
#import "Utils.h"
#import "FacebookViewController.h"
#import "CCLabelBMFontMultiline.h"

@class GameManager;

@interface CareerLayer : CCLayer <UIAlertViewDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate>{
    UIViewController *mailController;
    
    ALuint tutorSound;
    ALuint scoreSound;
    ALuint scoreSoundErase;
    ALuint fanfareSound;
    
    CCLayerColor *zoomBase;
    CGPoint zbLastPos;
    
    CCLayer *tutorLayer;
    CCLayerColor *tutorBlackout;
    CCLabelBMFontMultiline *tutorTxt;
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
    
    CCSprite *buyFullOff;
    CCSprite *buyFullOn;
    BOOL buyVisible;
    
    int buttonWidth;//zatim nefachci - mrknout se
    int buttonHeight;//zatim nefachci - mrknout se
    
    CCMenuItem *infoOff;
    CCMenuItem *infoOn;
    
    CCMenuItemToggle *toggleItem;
        
    int prog;
    float total;//progress bar width
    int percent;    
    BOOL panelActive;
    
    int score;
    
    int diff;//default diff
    
    BOOL blink;
    BOOL isRetina;
    
    BOOL endCareer;
    BOOL endCareerRoleta;
    int citiesFull;
    
    BOOL careerSoundPlay;
    
    CCParticleSystem *dustSystem;
    
    UIPanGestureRecognizer *panGestureRecognizer;
    UIPinchGestureRecognizer *pinchGestureRecognizer;    
    UITapGestureRecognizer *singleTapGestureRecognizer;
    


}

@end
