//
//  GameManager.m
//  Logic
//
//  Created by Pavel Krusek on 5/8/11.
//  Copyright 2011 Born2BeChild. All rights reserved.
//

#import "GameManager.h"
#import "GameScene.h"


@implementation GameManager

@synthesize isMusicON, isSoundEffectsON;
static GameManager* _sharedGameManager = nil;

+(GameManager*)sharedGameManager 
{
    @synchronized([GameManager class])
    {
        if(!_sharedGameManager)
            [[self alloc] init]; 
        return _sharedGameManager;
    }
    return nil; 
}

+(id)alloc 
{
    @synchronized ([GameManager class])
    {
        NSAssert(_sharedGameManager == nil,
                 @"Attempted to allocated a second instance of the Game Manager singleton");
        _sharedGameManager = [super alloc];
        return _sharedGameManager;
    }
    return nil;  
}

-(id)init 
{
    self = [super init];
    if (self != nil) {
        CCLOG(@"Game Manager Singleton, init");
        currentScene = kNoSceneUninitialized;        
    }
    return self;
}

-(void)runSceneWithID:(SceneTypes)sceneID {
    SceneTypes oldScene = currentScene;
    currentScene = sceneID;
    
    id sceneToRun = nil;
    switch (sceneID) {
        case kGameScene: 
            sceneToRun = [GameScene node];
            break;
        default:
            CCLOG(@"Unknown ID, cannot switch scenes");
            return;
            break;
    }
    
    if (sceneToRun == nil) {
        // Revert back, since no new scene was found
        currentScene = oldScene;
        return;
    }
    
    if ([[CCDirector sharedDirector] runningScene] == nil) {
        [[CCDirector sharedDirector] runWithScene:sceneToRun];
        
    } else {
        
        [[CCDirector sharedDirector] replaceScene:sceneToRun];
    }
    
}

@end
