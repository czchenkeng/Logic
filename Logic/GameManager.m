//
//  GameManager.m
//  Logic
//
//  Created by Pavel Krusek on 5/8/11.
//  Copyright 2011 Born2BeChild. All rights reserved.
//

#import "GameManager.h"
#import "GameScene.h"


@interface GameManager (PrivateMethods)
- (NSDictionary *) getSoundEffectsListForSceneWithID:(SceneTypes)sceneID;
- (void) loadLoopSounds:(NSNumber *)sceneIDNumber;
- (void) generatePatterns:(NSMutableArray *)pattern colors:(int)colors pins:(int)pins;
@end

@implementation GameManager

@synthesize managerSoundState, gameData, controller, listOfSoundEffectFiles, soundEffectsState, oldScene, mainTutor;

static GameManager* _sharedGameManager = nil;

+ (GameManager*) sharedGameManager {
    @synchronized([GameManager class])
    {
        if(!_sharedGameManager)
            [[self alloc] init]; 
        return _sharedGameManager;
    }
    return nil; 
}

+ (id) alloc {
    @synchronized ([GameManager class])
    {
        NSAssert(_sharedGameManager == nil,
                 @"Logic debug: Attempted to allocated a second instance of the Game Manager singleton");
        _sharedGameManager = [super alloc];
        return _sharedGameManager;
    }
    return nil;  
}

- (id) init {
    self = [super init];
    if (self != nil) {
        CCLOG(@"Logic debug: Game Manager Singleton, init");
        mainTutor = NO;
        loopingSfx = [[NSMutableArray alloc] init];
        [SimpleAudioEngine sharedEngine].backgroundMusicVolume = musicVolume;
        hasAudioBeenInitialized = NO;
        soundEngine = nil;
        managerSoundState = kAudioManagerUninitialized;
        currentScene = kNoSceneUninitialized;
        musicVolume = SETTINGS_MUSIC_VOLUME;
        soundVolume = SETTINGS_SOUND_VOLUME;
        currentDifficulty = kMedium;
        isCareer = NO;//pak nacist z databaze
        gameData = [[GameData alloc] init];
        settings startSettings = [gameData getSettings];
        musicVolume = startSettings.musicLevel;
        soundVolume = startSettings.soundLevel;
        currentDifficulty = startSettings.gameDifficulty;
        [self setMusicVolume:musicVolume];
    }
    return self;
}

- (void) getScorePatterns {
    patterns4 = [[NSMutableArray alloc] init];
    patterns5 = [[NSMutableArray alloc] init];
    patterns6 = [[NSMutableArray alloc] init];
    [self generatePatterns:patterns4 colors:8 pins:4];
    [self generatePatterns:patterns5 colors:8 pins:5];
    [self generatePatterns:patterns6 colors:8 pins:6];
    CCLOG(@"kolik toho je p6? %i", [patterns6 count]);
}

- (NSMutableArray *) getGamePattern {
    NSMutableArray *patterns;
    switch (currentDifficulty) {
        case kEasy:
            patterns = patterns4;
            break;
        case kMedium:
            patterns = patterns5;
            break;
        case kHard:
            patterns = patterns6;
            break;
    }
    
    return patterns;
}

- (void) generatePatterns:(NSMutableArray *)pattern colors:(int)colors pins:(int)pins {
    int patternCount = (int)pow(colors, pins);
    int c = 0;
    for (int i = 0; i < patternCount; i++) {
        NSMutableArray *newPattern = [[NSMutableArray alloc] initWithCapacity:pins];
        [newPattern addObject:[NSNumber numberWithInt:i%colors]]; 
        for (int pin = 1; pin < pins; pin++) {
            [newPattern addObject:[NSNumber numberWithInt:i % (int)pow(colors, pin + 1) / (int)pow(colors, pin)]];
        }
        c++;
        [pattern addObject:newPattern];
    }
    CCLOG(@"****\n****\n****\n****\n****\n****\nKOLIK TOHO JE? %i pri %i****\n****\n****\n****\n****\n****\n", c, pins);
}

- (void) savePattern:(NSMutableArray *)pattern {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    if ([paths count] > 0) {
        NSString  *arrayPath = [[paths objectAtIndex:0] 
                                stringByAppendingPathComponent:@"pattern.out"];
        
        [pattern writeToFile:arrayPath atomically:YES];
    }
    
}

- (NSMutableArray *) readPattern {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSMutableArray *arrayFromFile;
    
    if ([paths count] > 0) {
        NSString  *arrayPath = [[paths objectAtIndex:0] 
                                stringByAppendingPathComponent:@"pattern.out"];
        arrayFromFile = [NSMutableArray arrayWithContentsOfFile:arrayPath];
        CCLOG(@"\n\n\n\n\nKOLIK 11111? %i\n\n\n\n\n", [arrayFromFile count]);
    }
    
    CCLOG(@"\n\n\n\n\nKOLIK? %i\n\n\n\n\n", [arrayFromFile count]);
    
    return arrayFromFile;
}

- (FacebookViewController *) facebookController:(CGRect)rect {
    controller = [[FacebookViewController alloc] initWithFrame:rect];
    return controller;
}

- (void) updateSettings {
    [gameData updateSettingsWithDifficulty:currentDifficulty andMusicLevel:musicVolume andSoundLevel:soundVolume];
}

- (BOOL) gameInProgress {
    return [gameData isActiveGame];
}

- (float) musicVolume {
    return musicVolume;
}

- (void) setMusicVolume:(float)musicValue {
    musicVolume = musicValue;
    [SimpleAudioEngine sharedEngine].backgroundMusicVolume = musicValue;
}

- (float) soundVolume {
    return soundVolume;
}

- (void) duckling:(float)soundLevel {
    [SimpleAudioEngine sharedEngine].backgroundMusicVolume = soundLevel;
}

- (void) setSoundVolume:(float)soundValue{
    soundVolume = soundValue;
    [SimpleAudioEngine sharedEngine].effectsVolume = soundValue;
    
}

- (BOOL) isTutor {
    settings gameSettings = [gameData getSettings];
    return gameSettings.tutor == 0 ? NO : YES;
}

- (void) setIsTutor:(BOOL)isTutor {
    [gameData updateSettingsWithTutor];
}

- (GameDifficulty) currentDifficulty {
    return currentDifficulty;
}

- (void) setCurrentDifficulty:(GameDifficulty)diff {
    currentDifficulty = diff;
    [self updateSettings];
}

- (void) loadAudioForSceneWithID:(NSNumber*)sceneIDNumber {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    SceneTypes sceneID = (SceneTypes)[sceneIDNumber intValue];
    if (managerSoundState == kAudioManagerInitializing) {
        int waitCycles = 0;
        while (waitCycles < AUDIO_MAX_WAITTIME) {
            [NSThread sleepForTimeInterval:0.1f];
            if ((managerSoundState == kAudioManagerReady) || (managerSoundState == kAudioManagerFailed)) {
                break;
            }
            waitCycles = waitCycles + 1;
        }
    }
    
    if (managerSoundState == kAudioManagerFailed) {
        return;
    }
    
    NSDictionary *soundEffectsToLoad = [self getSoundEffectsListForSceneWithID:sceneID];
    CCLOG(@"*****************************************\n*****************************************\nEFFECTS FOR SCENE LOAD %@*****************************************\n*****************************************\n", [self getSoundEffectsListForSceneWithID:sceneID]);
    if (soundEffectsToLoad == nil) {
        CCLOG(@"Error reading SoundEffects.plist");
        return;
    }

    for( NSString *keyString in soundEffectsToLoad ) {
        CCLOG(@"Audio key:%@ File:%@ -> loaded OK", keyString,[soundEffectsToLoad objectForKey:keyString]);
        [soundEngine preloadEffect:[soundEffectsToLoad objectForKey:keyString]];
        [soundEffectsState setObject:[NSNumber numberWithBool:SFX_LOADED] forKey:keyString];
        
    }
    [pool release];
}

- (void) unloadAudioForSceneWithID:(NSNumber*)sceneIDNumber {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    SceneTypes sceneID = (SceneTypes)[sceneIDNumber intValue];
    if (sceneID == kNoSceneUninitialized) {
        return;
    }
    
    
    NSDictionary *soundEffectsToUnload = [self getSoundEffectsListForSceneWithID:sceneID];
    CCLOG(@"*****************************************\n*****************************************\nEFFECTS FOR SCENE UNLOAD %@*****************************************\n*****************************************\n", [self getSoundEffectsListForSceneWithID:sceneID]);
    if (soundEffectsToUnload == nil) {
        CCLOG(@"Error reading SoundEffects.plist");
        return;
    }
    if (managerSoundState == kAudioManagerReady) {
        for( NSString *keyString in soundEffectsToUnload )
        {
            [soundEffectsState setObject:[NSNumber numberWithBool:SFX_NOTLOADED] forKey:keyString];
            [soundEngine unloadEffect:keyString];
            CCLOG(@"\nUnloading Audio Key:%@ File:%@", keyString,[soundEffectsToUnload objectForKey:keyString]);
            
        }
    }
    [pool release];
}

- (void) runSceneWithID:(SceneTypes)sceneID andTransition:(TransitionTypes)transitionID {
    oldScene = currentScene;
    currentScene = sceneID;
    
    id transition;
    
    CCScene *sceneToRun = nil;
    switch (sceneID) {
        case kPreloaderScene:
            sceneToRun = [PreloaderScene node];
            break;
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
        case kLogoScene: 
            sceneToRun = [LogoScene node];
            break;
        default:
            CCLOG(@"Logic debug: Unknown ID, cannot switch scenes");
            return;
            break;
    }
    
    if (sceneToRun == nil) {
        // Revert back, since no new scene was found
        CCLOG(@"je tady?");
        currentScene = oldScene;
        return;
    }
    
    if (currentScene != oldScene) {//because of replace with same scene
        [self performSelectorInBackground:@selector(loadAudioForSceneWithID:) withObject:[NSNumber numberWithInt:sceneID]];
    }
    [self loadLoopSounds:[NSNumber numberWithInt:sceneID]];
    
    if ([[CCDirector sharedDirector] runningScene] == nil) {
        [[CCDirector sharedDirector] runWithScene:sceneToRun];
        
    } else {
        float timeTransition = .3;
        
        switch (transitionID) {
            case kSlideInR: 
                transition = [CCTransitionSlideInR transitionWithDuration:timeTransition scene:sceneToRun];
                break;
            case kSlideInL: 
                transition = [CCTransitionSlideInL transitionWithDuration:timeTransition scene:sceneToRun];
                break;
            case kLogicTrans:
                transition = [CCTransitionLogic transitionWithDuration:0.7 scene:sceneToRun];
                break;
            case kNoTransition:
                transition = [CCTransitionFade transitionWithDuration:timeTransition scene:sceneToRun];
                break;
            case kFadeTrans:
                transition = [CCTransitionFade transitionWithDuration:0.2 scene:sceneToRun];
                break;
            case kLogicTransRev:
                transition = [CCTransitionLogicRev transitionWithDuration:0.7 scene:sceneToRun];
                break;
            default:
                CCLOG(@"Logic debug: Unknown ID, default transition");
                transition = [CCTransitionSlideInR transitionWithDuration:timeTransition scene:sceneToRun];
                break;
        }
        
//        if (transitionID == kLogoScene) {
//            [[CCDirector sharedDirector] replaceScene:sceneToRun];
//        } else {
            [[CCDirector sharedDirector] replaceScene:transition];
        //}
    }
    if (currentScene != oldScene) {
        [self performSelectorInBackground:@selector(unloadAudioForSceneWithID:) withObject:[NSNumber numberWithInt:oldScene]];
    }
}

- (NSString*) formatSceneTypeToString:(SceneTypes)sceneID {
    NSString *result = nil;
    switch(sceneID) {
        case kNoSceneUninitialized:
            result = @"kNoSceneUninitialized";
            break;
        case kPreloaderScene:
            result = @"kPreloaderScene";
            break;
        case kGameScene:
            result = @"kGameScene";
            break;
        case kMainScene:
            result = @"kMainScene";
            break;
        case kSettingsScene:
            result = @"kSettingsScene";
            break;
        case kCareerScene:
            result = @"kCareerScene";
            break;
        case kScoreScene:
            result = @"kScoreScene";
            break;
        case kLogoScene:
            result = @"kLogoScene";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected SceneType."];
    }
    return result;
}


- (NSDictionary *) getSoundEffectsListForSceneWithID:(SceneTypes)sceneID {
    NSString *fullFileName = @"SoundEffects.plist";
    NSString *plistPath;
    
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"SoundEffects" ofType:@"plist"];
    }
    
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    if (plistDictionary == nil) {
        CCLOG(@"Error reading SoundEffects.plist");
        return nil;
    }
    if ((listOfSoundEffectFiles == nil) || ([listOfSoundEffectFiles count] < 1)) {
        NSLog(@"Before");
        [self setListOfSoundEffectFiles:[[NSMutableDictionary alloc] init]];
        NSLog(@"after");
        for (NSString *sceneSoundDictionary in plistDictionary) {
            [listOfSoundEffectFiles addEntriesFromDictionary:[plistDictionary objectForKey:sceneSoundDictionary]];
        }
        //CCLOG(@"SOUND EFFECTS:%@", listOfSoundEffectFiles);
        //CCLOG(@"Number of SFX filenames:%d", [listOfSoundEffectFiles count]);
    }
    
    if ((soundEffectsState == nil) || 
        ([soundEffectsState count] < 1)) {
        [self setSoundEffectsState:[[NSMutableDictionary alloc] init]];
        for (NSString *SoundEffectKey in listOfSoundEffectFiles) {
            [soundEffectsState setObject:[NSNumber numberWithBool:SFX_NOTLOADED] forKey:SoundEffectKey];
        }
    }
    NSString *sceneIDName = [self formatSceneTypeToString:sceneID];
    NSDictionary *soundEffectsList = [plistDictionary objectForKey:sceneIDName];
    //CCLOG(@"*****************************************\n*****************************************\neffects for scene %@*****************************************\n*****************************************\n", soundEffectsList);
    return soundEffectsList;
}



#pragma mark Init audio asynchronously
- (void) initAudioAsync {
    managerSoundState = kAudioManagerInitializing; 
    [CDSoundEngine setMixerSampleRate:CD_SAMPLE_RATE_MID];
    
    [CDAudioManager initAsynchronously:kAMM_FxPlusMusicIfNoOtherAudio];
    
    while ([CDAudioManager sharedManagerState] != kAMStateInitialised) 
    {
        [NSThread sleepForTimeInterval:0.1];
    }
    
    CDAudioManager *audioManager = [CDAudioManager sharedManager];
    if (audioManager.soundEngine == nil || audioManager.soundEngine.functioning == NO) {
        CCLOG(@"Logic debug: CocosDenshion failed to init, no audio will play.");
        managerSoundState = kAudioManagerFailed; 
    } else {
        [audioManager setResignBehavior:kAMRBStopPlay autoHandle:YES];
        soundEngine = [SimpleAudioEngine sharedEngine];
        managerSoundState = kAudioManagerReady;
        CCLOG(@"Logic debug: CocosDenshion is Ready");
    }
}

#pragma mark Setup audio engine
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

- (void) loadLoopSounds:(NSNumber *)sceneIDNumber {
    [self stopLoopSounds];
    
    SceneTypes sceneID = (SceneTypes)[sceneIDNumber intValue];
    NSDictionary *soundEffectsToLoop = [self getSoundEffectsListForSceneWithID:sceneID];
    
    NSRange match;    
    for( NSString *keyString in soundEffectsToLoop ) {
        match = [keyString rangeOfString: @"LOOP"];
        if (match.length > 0) {
            //CDSoundSource *sound = [[soundEngine soundSourceForFile:keyString] retain];
            CDSoundSource *sound = [soundEngine soundSourceForFile:[listOfSoundEffectFiles objectForKey:keyString]];
            CCLOG(@"Loop sound: %@ for key: %@ -> ready", sound, keyString);
            [loopingSfx addObject:sound];
            sound.looping = YES;
            //sound.gain = 0.1f;
            //[sound play];
        }
    }
}

- (void) playLoopSounds {
    for (CDSoundSource *s in loopingSfx) {
        [s play];
    }
}

- (void) pauseLoopSounds {
    for (CDSoundSource *s in loopingSfx) {
        [s stop];
    }
}

- (void) stopLoopSounds {
    for (CDSoundSource *s in loopingSfx) {
        [s stop];
        //[s release];
    }
    
    if (loopingSfx.count > 0) {
        [loopingSfx removeAllObjects];
    }
}

- (void) playBackgroundTrack:(NSString *)trackFileName {
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

- (void) stopSoundEffect:(ALuint)soundEffectID {
    if (managerSoundState == kAudioManagerReady) {
        [soundEngine stopEffect:soundEffectID];
    }
}

- (ALuint) playSoundEffect:(NSString*)soundEffectKey {
    ALuint soundID = 0;
    if (managerSoundState == kAudioManagerReady) {
        NSNumber *isSFXLoaded = [soundEffectsState objectForKey:soundEffectKey];
        if ([isSFXLoaded boolValue] == SFX_LOADED) {
            soundID = [soundEngine playEffect:[listOfSoundEffectFiles objectForKey:soundEffectKey]];
        } else {
            CCLOG(@"GameMgr: SoundEffect %@ is not loaded, cannot play.",soundEffectKey);
        }
    } else {
        CCLOG(@"GameMgr: Sound Manager is not ready, cannot play %@", soundEffectKey);
    }
    return soundID;
}


- (void) dealloc {
    [patterns4 release];
    patterns4 = nil;
    [patterns5 release];
    patterns5 = nil;
    [patterns6 release];
    patterns6 = nil;
    [controller release];
    [loopingSfx release];
    loopingSfx = nil;
    [super dealloc];
}

@end
