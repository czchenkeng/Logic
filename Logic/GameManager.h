//
//  GameManager.h
//  Logic
//
//  Created by Pavel Krusek on 5/8/11.
//  Copyright 2011 Born2BeChild. All rights reserved.
//

#import "Constants.h"

@interface GameManager : NSObject {
    BOOL isMusicON;
    BOOL isSoundEffectsON;
    GameDifficulty currentDifficulty;
    SceneTypes currentScene;
}

@property (readwrite) BOOL isMusicON;
@property (readwrite) BOOL isSoundEffectsON;
@property (readwrite) GameDifficulty currentDifficulty;

+ (GameManager*) sharedGameManager;
- (void) runSceneWithID:(SceneTypes)sceneID;
//- (void) setGameDifficulty:(GameDifficulty)difficultyID;

@end
