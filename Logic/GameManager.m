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

@synthesize isMusicON, isSoundEffectsON, currentDifficulty, managerSoundState, musicVolume, soundVolume;
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
                 @"Logic debug: Attempted to allocated a second instance of the Game Manager singleton");
        _sharedGameManager = [super alloc];
        return _sharedGameManager;
    }
    return nil;  
}

-(id)init 
{
    self = [super init];
    if (self != nil) {
        CCLOG(@"Logic debug: Game Manager Singleton, init");
        musicVolume = 0.50;
        soundVolume = 0.70;
        [SimpleAudioEngine sharedEngine].backgroundMusicVolume = musicVolume;
        isMusicON = YES;
        isSoundEffectsON = YES;
        hasAudioBeenInitialized = NO;
        soundEngine = nil;
        managerSoundState = kAudioManagerUninitialized;
        currentDifficulty = kMedium;
        currentScene = kNoSceneUninitialized;        
    }
    return self;
}

- (float) musicVolume {
    return musicVolume;
}

- (void) setMusicVolume:(float)musicValue {
    musicVolume = musicValue;
    if (musicValue < 0.05) {
        musicValue = 0.00;
    }
    [SimpleAudioEngine sharedEngine].backgroundMusicVolume = musicValue;
}

//-(void)unloadAudioForSceneWithID:(NSNumber*)sceneIDNumber {
//    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
//    SceneTypes sceneID = (SceneTypes)[sceneIDNumber intValue];
//    if (sceneID == kNoSceneUninitialized) {
//        return; // Nothing to unload
//    }
//    
//    
//    NSDictionary *soundEffectsToUnload = 
//    [self getSoundEffectsListForSceneWithID:sceneID];
//    if (soundEffectsToUnload == nil) {
//        CCLOG(@"Error reading SoundEffects.plist");
//        return;
//    }
//    if (managerSoundState == kAudioManagerReady) {
//        // Get all of the entries and unload
//        for( NSString *keyString in soundEffectsToUnload )
//        {
//            [soundEffectsState setObject:[NSNumber numberWithBool:SFX_NOTLOADED] forKey:keyString];
//            [soundEngine unloadEffect:keyString];
//            CCLOG(@"\nUnloading Audio Key:%@ File:%@", 
//                  keyString,[soundEffectsToUnload objectForKey:keyString]);
//            
//        }
//    }
//    [pool release];
//}

-(void)runSceneWithID:(SceneTypes)sceneID {
    SceneTypes oldScene = currentScene;
    currentScene = sceneID;
    
    id sceneToRun = nil;
    switch (sceneID) {
        case kGameScene: 
            sceneToRun = [GameScene node];
            break;
        case kMainScene: 
            sceneToRun = [MainScene node];
            break;
        case kSettingsScene: 
            sceneToRun = [SettingsScene node];
            break;
        case kCareerScene: 
            sceneToRun = [CareerScene node];
            break;
        case kScoreScene: 
            sceneToRun = [ScoreScene node];
            break;            
        default:
            CCLOG(@"Logic debug: Unknown ID, cannot switch scenes");
            return;
            break;
    }
    
    if (sceneToRun == nil) {
        // Revert back, since no new scene was found
        currentScene = oldScene;
        return;
    }
    
    //[self performSelectorInBackground:@selector(loadAudioForSceneWithID:) withObject:[NSNumber numberWithInt:sceneID]];
    
    if ([[CCDirector sharedDirector] runningScene] == nil) {
        [[CCDirector sharedDirector] runWithScene:sceneToRun];
        
    } else {
        float timeTransition = 0.5;
        //CCTransitionSlideInR *transition = [CCTransitionSlideInR transitionWithDuration:timeTransition scene:sceneToRun];
        //CCTransitionSlideInL *transition = [CCTransitionSlideInL transitionWithDuration:timeTransition scene:sceneToRun];
        //CCTransitionSlideInB *transition = [CCTransitionSlideInB transitionWithDuration:timeTransition scene:sceneToRun];
        //CCTransitionSlideInT *transition = [CCTransitionSlideInT transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionSplitCols transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionSplitRows transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionTurnOffTiles transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionZoomFlipAngular transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionZoomFlipX transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionZoomFlipY transitionWithDuration:timeTransition scene:sceneToRun];
        id transition = [CCTransitionShrinkGrow transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionSceneOriented transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionRotoZoom transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionRadialCW transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionRadialCCW transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionPageTurn transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionMoveInT transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionMoveInR transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionMoveInL transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionMoveInB transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionJumpZoom transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionFlipY transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionFlipX  transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionFlipAngular transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionFadeUp transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionFadeTR transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionFadeDown transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionFadeBL transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionFade transitionWithDuration:timeTransition scene:sceneToRun];
        //id transition = [CCTransitionCrossFade transitionWithDuration:timeTransition scene:sceneToRun];
        
        [[CCDirector sharedDirector] replaceScene:transition];

        //[[CCDirector sharedDirector] replaceScene:sceneToRun];
    }
    //[self performSelectorInBackground:@selector(unloadAudioForSceneWithID:) withObject:[NSNumber numberWithInt:oldScene]];

}

//CCFadeTransition: Fade to a specific color and back. ␣ 
//CCFadeTRTransition (three more variations): Tiles flip over to reveal
//new scene.
//␣ CCJumpZoomTransition: Scene bounces and gets smaller, new scene does the reverse.
//␣ CCMoveInLTransition (three more variations): Scene moves out, new scene moves in at the same time, either from left, right, top or bottom.
//␣ CCOrientedTransitionScene (six more variations): A variety of transitions flipping the whole scene around
//␣ CCPageTurnTransition: An effect like turning a page. ␣ CCRotoZoomTransition: Scene rotates and gets smaller, new scene
//does reverse.
//␣ CCShrinkGrowTransition: Current scene shrinks, new scene grows over it.

//␣ CCSplitColsTransition (one variation): Columns of scene move up or down to reveal new scene.
//␣ CCTurnOffTilesTransition: Tiles randomly replaced by tiles of new scene.

- (void) initAudioAsync {
    // Initializes the audio engine asynchronously
    managerSoundState = kAudioManagerInitializing; 
    // Indicate that we are trying to start up the Audio Manager
    [CDSoundEngine setMixerSampleRate:CD_SAMPLE_RATE_MID];
    
    //Init audio manager asynchronously as it can take a few seconds
    //The FXPlusMusicIfNoOtherAudio mode will check if the user is
    // playing music and disable background music playback if 
    // that is the case.
    [CDAudioManager initAsynchronously:kAMM_FxPlusMusicIfNoOtherAudio];
    
    //Wait for the audio manager to initialise
    while ([CDAudioManager sharedManagerState] != kAMStateInitialised) 
    {
        [NSThread sleepForTimeInterval:0.1];
    }
    
    //At this point the CocosDenshion should be initialized
    // Grab the CDAudioManager and check the state
    CDAudioManager *audioManager = [CDAudioManager sharedManager];
    if (audioManager.soundEngine == nil || 
        audioManager.soundEngine.functioning == NO) {
        CCLOG(@"Logic debug: CocosDenshion failed to init, no audio will play.");
        managerSoundState = kAudioManagerFailed; 
    } else {
        [audioManager setResignBehavior:kAMRBStopPlay autoHandle:YES];
        soundEngine = [SimpleAudioEngine sharedEngine];
        managerSoundState = kAudioManagerReady;
        CCLOG(@"Logic debug: CocosDenshion is Ready");
    }
}

- (void) setupAudioEngine {
    if (hasAudioBeenInitialized == YES) {
        return;
    } else {
        hasAudioBeenInitialized = YES; 
        NSOperationQueue *queue = [[NSOperationQueue new] autorelease];
        NSInvocationOperation *asyncSetupOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(initAudioAsync) object:nil];
        [queue addOperation:asyncSetupOperation];
        [asyncSetupOperation autorelease];
    }
}

- (void) playBackgroundTrack:(NSString*)trackFileName {
    CCLOG(@"Logic: MUSIC PLAYING %@", trackFileName);
    if ((managerSoundState != kAudioManagerReady) && (managerSoundState != kAudioManagerFailed)) {        
        int waitCycles = 0;
        while (waitCycles < AUDIO_MAX_WAITTIME) {
            [NSThread sleepForTimeInterval:0.1f];
            if ((managerSoundState == kAudioManagerReady) || 
                (managerSoundState == kAudioManagerFailed)) {
                break;
            }
            waitCycles = waitCycles + 1;
        }
    }
    
    if (managerSoundState == kAudioManagerReady) {
        if ([soundEngine isBackgroundMusicPlaying]) {
            [soundEngine stopBackgroundMusic];
        }
        [soundEngine preloadBackgroundMusic:trackFileName];
        [soundEngine playBackgroundMusic:trackFileName loop:YES];
    }
}

@end
