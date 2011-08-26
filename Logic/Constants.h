//
//  Constants.h
//  Logic
//
//  Created by Pavel Krusek on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define MIN_DISTANCE_SWIPE_X 200
#define MIN_DISTANCE_SWIPE_Y 120
#define LEVEL_SWIPE_AFTER_ROW 7
#define LEVEL_SWIPE 30
//#define LEVEL_DEAD_FIGURES_MASK_HEIGHT 5
#define LEVEL_DEAD_FIGURES_MASK_HEIGHT 0
#define LEVEL_DISLOCATION 40
#define LEVEL_FIGURE_MAX_Y_MOVE 400

#define LEFT_BUTTON_TOP_X 33.00
#define LEFT_BUTTON_TOP_Y 481.00

#define RIGHT_BUTTON_TOP_X 287.00
#define RIGHT_BUTTON_TOP_Y 481.00

#define SETTINGS_MUSIC_VOLUME 0.50
#define SETTINGS_SOUND_VOLUME 0.70

#define LEVEL_MIN_PRESS_DURATION 0.05

typedef struct {
    int gameDifficulty;
    float musicLevel;
    float soundLevel;
    int tutor;
} settings;

typedef struct {
    int color;
    CGPoint position;
} deadFigure;

typedef struct {
    int fid;
    int color;
    int place;
    CGPoint position;
} activeFigure;

typedef struct {
    int row;
    int places;
    int colors;
} gameRow;

typedef struct {
    int difficulty;
    int activeRow;
    int career;
    int score;
    int gameTime;
} gameInfo;

typedef struct {
    int idCity;
    int score;
    CGPoint position;
} city;

typedef enum {
    kButtonInfo,
    kButtonSettings,
    kButtonSinglePlay,
    kButtonCareerPlay,
    kButtonBack,  
    kButtonScore,
    kButtonPause,
    kButtonFb,
    kButtonMail,
    kButtonEraseCareer,
    kButtonContinuePlay,
    kButtonNewGame,
    kButtonEndGame,
    kButtonReplay,
    kButtonContinue,
    kButtonGameMenu,
    kButtonSkipTutor,
    kButtonNeverShow
} buttonTypes;

typedef enum {
    kNoSceneUninitialized = 0,
    kGameScene = 1,
    kMainScene = 2,
    kSettingsScene = 3,
    kCareerScene = 4,
    kScoreScene = 5,
    kPreloaderScene = 6
} SceneTypes;

typedef enum {
    kTutorFirst = 0,
    kTutorSecond = 1,
    kTutorThird = 2
} TutorSteps;

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
    kFigureZoom
} ActionTypes;

//MUSIC, SOUNDS
#define AUDIO_MAX_WAITTIME 150
#define BACKGROUND_TRACK_MAIN @"Logic-main-theme.mp3"
#define BACKGROUND_TRACK_LEVEL @"Logic-level-ambient.mp3"
#define BACKGROUND_TRACK_PAUSE @"Logic-main-pauzatheme.mp3"
#define BACKGROUND_TRACK_WINNER @"Logic-level-scoretheme.mp3"

typedef enum {
    kAudioManagerUninitialized = 0,
    kAudioManagerFailed = 1,
    kAudioManagerInitializing = 2,
    kAudioManagerInitialized = 100,
    kAudioManagerLoading = 200,
    kAudioManagerReady = 300
    
} GameManagerSoundState;

#define SFX_NOTLOADED NO
#define SFX_LOADED YES

#define PLAYSOUNDEFFECT(...) [[GameManager sharedGameManager] playSoundEffect:@#__VA_ARGS__]
#define STOPSOUNDEFFECT(...) [[GameManager sharedGameManager] stopSoundEffect:@#__VA_ARGS__]









