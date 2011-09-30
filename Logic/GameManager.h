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
#import "PreloaderScene.h"
#import "LogoScene.h"
#import "SimpleAudioEngine.h"
#import "GameData.h"
#import "FacebookViewController.h"
#import "CCTransition.h"
#import "ScoreCalc.h"

@interface GameManager : NSObject {
    BOOL hasAudioBeenInitialized;
    GameManagerSoundState managerSoundState;
    SimpleAudioEngine *soundEngine;
    NSMutableDictionary *listOfSoundEffectFiles; 
    NSMutableDictionary *soundEffectsState;
    NSMutableArray *loopingSfx;
    
    GameDifficulty currentDifficulty;
    SceneTypes currentScene;
    SceneTypes oldScene;
    float musicVolume;
    float soundVolume;
    GameData *gameData;
    FacebookViewController *controller;
    BOOL gameInProgress;
    BOOL isCareer;
    BOOL isTutor;
    BOOL mainTutor;
}

@property (readwrite) GameDifficulty currentDifficulty;
@property (nonatomic, retain) GameData *gameData;
@property (nonatomic, retain) FacebookViewController *controller;
@property (readonly) BOOL gameInProgress;
@property (readonly) SceneTypes oldScene;

@property (readwrite) GameManagerSoundState managerSoundState; 
@property (nonatomic, retain) NSMutableDictionary *listOfSoundEffectFiles; 
@property (nonatomic, retain) NSMutableDictionary *soundEffectsState;
@property (readwrite) float musicVolume;
@property (readwrite) float soundVolume;
@property (readwrite) BOOL isTutor;
@property (readwrite) BOOL mainTutor;

+ (GameManager*) sharedGameManager;
- (void) runSceneWithID:(SceneTypes)sceneID andTransition:(TransitionTypes)transitionID;
- (FacebookViewController *) facebookController;

- (void) setupAudioEngine; 
- (ALuint) playSoundEffect:(NSString*)soundEffectKey; 
- (void) stopSoundEffect:(ALuint)soundEffectID; 
- (void) playBackgroundTrack:(NSString*)trackFileName;
- (void) stopLoopSounds;
- (void) pauseLoopSounds;
- (void) playLoopSounds;

- (void) updateSettings;

- (void) duckling:(float)soundLevel;

//score
- (void) savePattern:(NSMutableArray *)pattern;
- (NSMutableArray *) readPattern;

@end
