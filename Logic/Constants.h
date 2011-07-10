//
//  Constants.h
//  Logic
//
//  Created by Pavel Krusek on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define MIN_DISTANCE_SWIPE_X 200
#define MIN_DISTANCE_SWIPE_Y 20
#define LEVEL_SWIPE_AFTER_ROW 7
#define LEVEL_DEAD_FIGURES_MASK_HEIGHT 66
#define LEVEL_DISLOCATION 40
#define LEVEL_FIGURE_MAX_Y_MOVE 400

#define AUDIO_MAX_WAITTIME 150
#define BACKGROUND_TRACK_MAIN @"main_theme.mp3"

#define LEFT_BUTTON_TOP_X 33.00
#define LEFT_BUTTON_TOP_Y 481.00

#define RIGHT_BUTTON_TOP_X 287.00
#define RIGHT_BUTTON_TOP_Y 481.00


typedef struct {
    int gameDifficulty;
    float musicLevel;
    float soundLevel;
} settings;

typedef struct {
    int row;
    int color;
    //int place;
    double posX;
    double posY;
} deadFigure;

typedef enum {
    kButtonInfo,
    kButtonSettings,
    kButtonSinglePlay,
    kButtonCareerPlay,
    kButtonBack,  
    kButtonScore,
    kButtonPause,
    kButtonFb
} buttonTypes;

typedef enum {
    kNoSceneUninitialized = 0,
    kGameScene = 1,
    kMainScene = 2,
    kSettingsScene = 3,
    kCareerScene = 4,
    kScoreScene = 5
} SceneTypes;

typedef enum {
    kNoTransition = 0,
    kSlideInR = 1,
    kSlideInL = 2,
    kLogicTrans = 3
} TransitionTypes;

typedef enum {
    kYellow = 0,
    kOrange = 1,
    kPink = 2,
    kRed = 3,
    kPurple = 4,
    kBlue = 5,
    kGreen = 6,
    kWhite = 7
} FigureTypes;

typedef enum {
    kEasy = 4,
    kMedium = 5,
    kHard = 6
} GameDifficulty;

typedef enum {
    kAudioManagerUninitialized = 0,
    kAudioManagerFailed = 1,
    kAudioManagerInitializing = 2,
    kAudioManagerInitialized = 100,
    kAudioManagerLoading = 200,
    kAudioManagerReady = 300
    
} GameManagerSoundState;