//#define IS_IPAD() (YES)
#define IS_IPAD() (NO)

#define kXoffsetiPad        64
#define kYoffsetiPad        32

#define SD_TEXTURE      @".plist"
#define HD_TEXTURE      @"-ipad.plist"

#define SD      @".plist"
#define HD      @"-hd.plist"

#define SD_PVR      @".pvr.ccz"
#define HD_PVR      @"-ipad.pvr.ccz"

#define kScreenHeight        480
#define kScreenWidth         320
#define kScreenCenterY       240
#define kScreenCenterX       160

//COMMON
#define ADJUST_X(__x__) (IS_IPAD() == YES ? ( __x__ * 2 ) + kXoffsetiPad : __x__)
#define ADJUST_Y(__y__) (IS_IPAD() == YES ? ( __y__ * 2 ) + kYoffsetiPad : __y__)

#define ADJUST_2(__v__) (IS_IPAD() == YES ? ( __v__ * 2 ) : __v__)

#define ADJUST_CCP(__p__) (IS_IPAD() == YES ? ccp( ( __p__.x * 2 ) + kXoffsetiPad, ( __p__.y * 2 ) + kYoffsetiPad ) : __p__)

#define ADJUST_CCP_OFFSET(__p__) (IS_IPAD() == YES ? ccp( __p__.x + kXoffsetiPad, __p__.y + kYoffsetiPad ) : __p__)

#define ADJUST_CCP_OFFSET2(__p__) (IS_IPAD() == YES ? ccp( ( __p__.x * 2 ), ( __p__.y * 2 ) ) : __p__)

#define ADJUST_CCP_ABOVE(__p__) (IS_IPAD() == YES ? ccp( ( __p__.x * 2 ) + kXoffsetiPad, ( __p__.y * 2 ) + kYoffsetiPad*2 ) : __p__)
#define ADJUST_CCP_RIGHT(__p__) (IS_IPAD() == YES ? ccp( ( __p__.x * 2 ) + kXoffsetiPad*2, ( __p__.y * 2 ) + kYoffsetiPad ) : __p__)

#define ADJUST_CCP_MAIN_SCENE(__p__) (IS_IPAD() == YES ? ccp( ( __p__.x * 2 ) + kXoffsetiPad, ( __p__.y * 2 ) ) : __p__)
#define ADJUST_CCP_MAIN_SCENE_GRASS(__p__) (IS_IPAD() == YES ? ccp( ( __p__.x * 2 ) + kXoffsetiPad, ( __p__.y * 2 ) + 31 ) : __p__)

#define REVERSE_CCP(__p__) (IS_IPAD() == NO ? ccp( ( __p__.x - kXoffsetiPad ) / 2, ( __p__.y - kYoffsetiPad ) / 2 ) : __p__)

//CUSTOM ADJUSTS
#define ADJUST_CCP_LEVEL_BASE(__p__) (IS_IPAD() == YES ? ccp( ( __p__.x * 2 ) + 24, ( __p__.y * 2 ) ) : __p__)
#define ADJUST_CCP_LEVEL_CODE(__p__) (IS_IPAD() == YES ? ccp( ( __p__.x * 2 ), ( __p__.y * 2 ) ) : __p__)

#define ADJUST_X_FIGURE_BASE(__x__) (IS_IPAD() == YES ? ( __x__ * 2 ) + kXoffsetiPad : __x__)
#define ADJUST_Y_FIGURE_BASE(__y__) (IS_IPAD() == YES ? ( __y__ * 2 ) + 32 : __y__)


//FILES HANDLING
#define SD_OR_HD(__filename__) (IS_IPAD() == YES ? [__filename__ stringByReplacingOccurrencesOfString:SD_TEXTURE withString:HD_TEXTURE] : __filename__)
#define SD1_OR_HD1(__filename__) (IS_IPAD() == YES ? [__filename__ stringByReplacingOccurrencesOfString:SD withString:HD] : __filename__)
#define SDPVR_OR_HDPVR(__filename__) (IS_IPAD() == YES ? [__filename__ stringByReplacingOccurrencesOfString:SD_PVR withString:HD_PVR] : __filename__)


/* POSITIONS */
//Common
#define kLeftNavigationButtonPosition       ADJUST_CCP_ABOVE( ccp(33.00, 481.00) )
#define kRightNavigationButtonPosition      ADJUST_CCP_ABOVE( ccp(287.00, 481.00) )

//Loader
#define kLoaderFactoryPosition            REVERSE_CCP( ccp(0, 0) )
#define kLoaderZakladMrakyPosition        REVERSE_CCP( ccp(0, 0) )
#define kLoaderBlesk1Position             REVERSE_CCP( ccp(143, 782) )
#define kLoaderBlesk2Position             REVERSE_CCP( ccp(76, 807) )
#define kLoaderBlesk3Position             REVERSE_CCP( ccp(51, 961) )
#define kLoaderBlesk4Position             REVERSE_CCP( ccp(4, 551) )
#define kLoaderHranyPosition              REVERSE_CCP( ccp(0, 7) )
//Main scene
#define kMainDoorsPosition          ADJUST_CCP_MAIN_SCENE( ccp(kScreenCenterX + 5, kScreenCenterY - 51) )
#define kMainLogoPosition           ADJUST_CCP_MAIN_SCENE( ccp(kScreenCenterX, kScreenCenterY + 164) )
#define kMainLogoShadowPosition     ADJUST_CCP_MAIN_SCENE( ccp(kScreenCenterX, kScreenCenterY + 162) )
#define kMainGrassPosition          ADJUST_CCP_MAIN_SCENE_GRASS( ccp(160, 16) )
#define kMainLightPosition          ADJUST_CCP_MAIN_SCENE( ccp(kScreenCenterX, 487) )
#define kMainRightGibOutPosition    ADJUST_CCP_MAIN_SCENE( ccp(1000.00, 367.00) )
#define kMainRightGibInPosition     ADJUST_CCP_MAIN_SCENE( ccp(225.50, 235.00) )
#define kMainLeftGibOutPosition     ADJUST_CCP_MAIN_SCENE( ccp(-700.00, 0.00) )
#define kMainLeftGibInPosition      ADJUST_CCP_MAIN_SCENE( ccp(100.00, 161.00) )
#define kMainLeftSingleGibInPosition  ADJUST_CCP_MAIN_SCENE( ccp(100.00, 176.00) )//3
#define kMainRightSingleGibInPosition ADJUST_CCP_MAIN_SCENE( ccp(225.50, 127.00) )//3
#define kMainRightGibButtonPosition ADJUST_CCP_OFFSET( ccp(66.00, 31.50) )
#define kMainLeftGibButtonPosition  ADJUST_CCP_OFFSET2( ccp(195.50, 35.50) )
//Level scene
#define kLevelCodeBasePosition      ADJUST_CCP( ccp(133, 455) )
#define kLevelBasePosition          ADJUST_CCP_LEVEL_BASE( ccp(0, 0) )
#define kLevelRotorRightPosition    ADJUST_CCP( ccp(259.00, 434.00) )
#define kLevelRotorLeftPosition     ADJUST_CCP( ccp(54.00, 430.00) )
#define kLevelSphereLightPosition   ADJUST_CCP( ccp(150.00, 411.00) )
#define kLevelMantlePosition        ADJUST_CCP( ccp(160.00, 456.00) )
#define kLevelSpherePosition        ADJUST_CCP( ccp(152, 474) )
//Settings scene
#define kSettingsScoreItemPosition   ADJUST_CCP( ccp(56.50, 377.50) )
#define kSettingsCareerItemPosition  ADJUST_CCP( ccp(56.50, 323.50) )
#define kSettingsMusicSliderPosition ADJUST_CCP( ccp(180, 252) )
#define kSettingsSoundSliderPosition ADJUST_CCP( ccp(180, 213) )
#define kSettingsRedLightPosition    ADJUST_CCP( ccp(61, 323.50) )

/* ANIMATIONS */
//Main scene
#define kMainLogoShadowMoveLeft     ADJUST_CCP_MAIN_SCENE( ccp(kScreenCenterX - 5, kScreenCenterY + 162) )
#define kMainLogoShadowMoveRight    ADJUST_CCP_MAIN_SCENE( ccp(kScreenCenterX + 5, kScreenCenterY + 162) )

/* TEXTURE FILES */
//Main scene
#define kMainMainTexture SD_OR_HD(@"Main.plist")
#define kMainHqTexture   SD_OR_HD(@"Hq.plist")
//Level scene
#define kLevelBgTexture SD_OR_HD(@"LevelBg.plist")
#define kLevelAnimationsTexture SD_OR_HD(@"Animations.plist")
#define kLevelLevelTexture SD_OR_HD(@"Level.plist")
#define kLevelLevelPvr SDPVR_OR_HDPVR(@"Animations.pvr.ccz")
//Settings
#define kSettingsTexture   SD_OR_HD(@"Settings.plist")
//Loader
#define kLoaderTexture   SD1_OR_HD1(@"Loader.plist")

/* PARTICLES */
#define kMainRainParticle SD_OR_HD(@"rain_phone.plist")


