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
#import "SimpleAudioEngine.h"

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
}

@property (readwrite) BOOL isMusicON;
@property (readwrite) BOOL isSoundEffectsON;
@property (readwrite) GameDifficulty currentDifficulty;
@property (readwrite) GameManagerSoundState managerSoundState;
@property (readwrite) float musicVolume;
@property (readwrite) float soundVolume;

+ (GameManager*) sharedGameManager;
- (void) runSceneWithID:(SceneTypes)sceneID;
- (void) setupAudioEngine;
- (void) playBackgroundTrack:(NSString*)trackFileName;
//- (void) setGameDifficulty:(GameDifficulty)difficultyID;

@end
