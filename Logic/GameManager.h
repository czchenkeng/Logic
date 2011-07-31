//
//  GameManager.h
//  Logic
//
//  Created by Pavel Krusek on 5/8/11.
//  Copyright 2011 Born2BeChild. All rights reserved.
//
#import "Constants.h"
#import "MainScene.h"
#import "SettingsScene.h"
#import "CareerScene.h"
#import "ScoreScene.h"
#import "SimpleAudioEngine.h"
#import "GameData.h"
#import "FacebookViewController.h"
#import "CCTransition.h"

@interface GameManager : NSObject {
    BOOL isMusicON;
    BOOL isSoundEffectsON;
    BOOL hasAudioBeenInitialized;
    SimpleAudioEngine *soundEngine;
    GameManagerSoundState managerSoundState;
    GameDifficulty currentDifficulty;
    SceneTypes currentScene;
    float musicVolume;
    float soundVolume;
    GameData *gameData;
    FacebookViewController *controller;
    BOOL gameInProgress;
}

@property (readwrite) BOOL isMusicON;
@property (readwrite) BOOL isSoundEffectsON;
@property (readwrite) GameDifficulty currentDifficulty;
@property (readwrite) GameManagerSoundState managerSoundState;
@property (readwrite) float musicVolume;
@property (readwrite) float soundVolume;
@property (nonatomic, retain) GameData *gameData;
@property (nonatomic, retain) FacebookViewController *controller;
@property (readwrite) BOOL gameInProgress;

+ (GameManager*) sharedGameManager;
- (void) runSceneWithID:(SceneTypes)sceneID andTransition:(TransitionTypes)transitionID;
- (void) setupAudioEngine;
- (void) playBackgroundTrack:(NSString*)trackFileName;
- (FacebookViewController *) facebookController:(CGRect)rect;
//- (void) setGameDifficulty:(GameDifficulty)difficultyID;

@end
