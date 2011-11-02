#ifdef HD_VERSION
    #define IS_IPAD() (YES)
    #define FLURRY_KEY @"5TYI8Q5VSL3P1ZK1LYVM"
#else
    #define IS_IPAD() (NO)
    #ifdef LITE_VERSION
        #define FLURRY_KEY @"5Q2159WHDQQI8879Q35D"
    #else
        #define FLURRY_KEY @"B7MQTF5UJ7QYMXQQ5AGW"
    #endif
#endif

#define kXoffsetiPad        64
#define kYoffsetiPad        32

#define SD_TEXTURE      @".plist"
#define HD_TEXTURE      @"-ipad.plist"

#define SD      @".plist"
#define HD      @"-hd.plist"

#define SD_PVR      @".pvr.ccz"
#define HD_PVR      @"-ipad.pvr.ccz"

#define SD_VIDEO      @"video"
#define HD_VIDEO      @"video-ipad"

#define kScreenHeight        480
#define kScreenWidth         320
#define kScreenCenterY       240
#define kScreenCenterX       160

//COMMON
#define ADJUST_X(__x__) (IS_IPAD() == YES ? ( __x__ * 2 ) + kXoffsetiPad : __x__)
#define ADJUST_Y(__y__) (IS_IPAD() == YES ? ( __y__ * 2 ) + kYoffsetiPad : __y__)
#define ADJUST_Y_MASK(__y__) (IS_IPAD() == YES ? ( __y__ * 2 ) + kYoffsetiPad*2 : __y__)

#define ADJUST_X_BUTTON_RIGHT(__x__) (IS_IPAD() == YES ? ( __x__ * 2 ) + kXoffsetiPad*2 : __x__)

#define ADJUST_2(__v__) (IS_IPAD() == YES ? ( __v__ * 2 ) : __v__)
#define REVERSE_ADJUST_2(__v__) (IS_IPAD() == YES ? ( __v__ ) : __v__ / 2)

#define ADJUST_CCP(__p__) (IS_IPAD() == YES ? ccp( ( __p__.x * 2 ) + kXoffsetiPad, ( __p__.y * 2 ) + kYoffsetiPad ) : __p__)

#define ADJUST_CCP_OFFSET(__p__) (IS_IPAD() == YES ? ccp( __p__.x + kXoffsetiPad, __p__.y + kYoffsetiPad ) : __p__)

#define ADJUST_CCP_OFFSET2(__p__) (IS_IPAD() == YES ? ccp( ( __p__.x * 2 ), ( __p__.y * 2 ) ) : __p__)
#define ADJUST_CCP_OFFSET_X(__p__) (IS_IPAD() == YES ? ccp( ( __p__.x * 2 + kXoffsetiPad), ( __p__.y * 2 ) ) : __p__)

#define ADJUST_CCP_ABOVE(__p__) (IS_IPAD() == YES ? ccp( ( __p__.x * 2 ) + kXoffsetiPad, ( __p__.y * 2 ) + kYoffsetiPad*2 ) : __p__)
#define ADJUST_CCP_ABOVE_NAV_BUTTONS(__p__) (IS_IPAD() == YES ? ccp( ( __p__.x * 2 ), ( __p__.y * 2 ) + kYoffsetiPad*2 ) : __p__)
#define ADJUST_CCP_ABOVE_NAV_BUTTONS_RIGHT(__p__) (IS_IPAD() == YES ? ccp( ( __p__.x * 2 + kXoffsetiPad*2), ( __p__.y * 2 ) + kYoffsetiPad*2 ) : __p__)
#define ADJUST_CCP_RIGHT(__p__) (IS_IPAD() == YES ? ccp( ( __p__.x * 2 ) + kXoffsetiPad*2, ( __p__.y * 2 ) + kYoffsetiPad ) : __p__)

#define ADJUST_CCP_MAIN_SCENE(__p__) (IS_IPAD() == YES ? ccp( ( __p__.x * 2 ) + kXoffsetiPad, ( __p__.y * 2 ) ) : __p__)
#define ADJUST_CCP_MAIN_SCENE_GRASS(__p__) (IS_IPAD() == YES ? ccp( ( __p__.x * 2 ) + kXoffsetiPad, ( __p__.y * 2 ) + 31 ) : __p__)

#define REVERSE_CCP(__p__) (IS_IPAD() == NO ? ccp( ( __p__.x - kXoffsetiPad ) / 2, ( __p__.y - kYoffsetiPad ) / 2 ) : __p__)

#define UIVIEW_CGRECT (IS_IPAD() == NO ?  CGRectMake(0, 0, 320, 480) : CGRectMake(0, 0, 768, 1024) )

//CUSTOM ADJUSTS
#define ADJUST_CCP_LEVEL_BASE(__p__) (IS_IPAD() == YES ? ccp( ( __p__.x * 2 ) + 24, ( __p__.y * 2 ) ) : __p__)
#define ADJUST_CCP_LEVEL_CODE(__p__) (IS_IPAD() == YES ? ccp( ( __p__.x * 2 ), ( __p__.y * 2 ) ) : __p__)

#define ADJUST_X_FIGURE_BASE(__x__) (IS_IPAD() == YES ? ( __x__ * 2 ) + kXoffsetiPad : __x__)
#define ADJUST_Y_FIGURE_BASE(__y__) (IS_IPAD() == YES ? ( __y__ * 2 ) + 32 : __y__)


//FILES HANDLING
#define SD_OR_HD(__filename__) (IS_IPAD() == YES ? [__filename__ stringByReplacingOccurrencesOfString:SD_TEXTURE withString:HD_TEXTURE] : __filename__)
#define SD1_OR_HD1(__filename__) (IS_IPAD() == YES ? [__filename__ stringByReplacingOccurrencesOfString:SD withString:HD] : __filename__)
#define SDPVR_OR_HDPVR(__filename__) (IS_IPAD() == YES ? [__filename__ stringByReplacingOccurrencesOfString:SD_PVR withString:HD_PVR] : __filename__)
#define SDVIDEO_OR_HDVIDEO(__filename__) (IS_IPAD() == YES ? [__filename__ stringByReplacingOccurrencesOfString:SD_VIDEO withString:HD_VIDEO] : __filename__)


/* POSITIONS */
//Common
#define kLeftNavigationButtonPosition       ADJUST_CCP_ABOVE_NAV_BUTTONS( ccp(33.00, 481.00) )
#define kRightNavigationButtonPosition      ADJUST_CCP_ABOVE_NAV_BUTTONS_RIGHT( ccp(287.00, 481.00) )

//Logo Video
#define kVideoOverlay               UIVIEW_CGRECT
//Loader
#define kLoaderFactoryPosition            REVERSE_CCP( ccp(0, 0) )
#define kLoaderZakladMrakyPosition        REVERSE_CCP( ccp(0, 0) )
#define kLoaderBlesk1Position             REVERSE_CCP( ccp(143, 782) )
#define kLoaderBlesk2Position             REVERSE_CCP( ccp(76, 807) )
#define kLoaderBlesk3Position             REVERSE_CCP( ccp(51, 961) )
#define kLoaderBlesk4Position             REVERSE_CCP( ccp(4, 551) )
#define kLoaderHranyPosition              REVERSE_CCP( ccp(0, 7) )
#define kLoaderBudikPosition              ADJUST_CCP_OFFSET_X( ccp(160.00, 36.50) )
#define kLoaderCiselnikPosition           ADJUST_CCP_OFFSET_X( ccp(160.00, 36.50) )
#define kLoaderRucickaPosition            ADJUST_CCP_OFFSET_X( ccp(159, -26) )
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
#define kMainDoorsOutPosition          ADJUST_CCP_MAIN_SCENE( ccp(kScreenCenterX - 190, kScreenCenterY - 51) )
//How To Layer
#define kHowToBgPosition          ADJUST_CCP_MAIN_SCENE( ccp(kScreenCenterX + 10, kScreenCenterY - 51) )
#define kHowToHeaderPosition          ADJUST_CCP_MAIN_SCENE( ccp(165.00, 323.50) )
#define kHowToCopyPosition          ADJUST_CCP_MAIN_SCENE( ccp(170.00, 285) )
#define kHowToScreenPosition          ADJUST_CCP_MAIN_SCENE( ccp(165, 165) )
#define kHowToFingerPosition          ADJUST_CCP_MAIN_SCENE( ccp(165, -100) )
#define kHowToFinger2Position          ADJUST_CCP_MAIN_SCENE( ccp(190, -153) )
#define kHowToPincl1Position          ADJUST_CCP_MAIN_SCENE( ccp(200, -270) )
#define kHowToRedPosition          ADJUST_CCP_MAIN_SCENE( ccp(120, -280) )
#define kHowToPincl2Position          ADJUST_CCP_MAIN_SCENE( ccp(200, -390) )
#define kHowToGreenPosition          ADJUST_CCP_MAIN_SCENE( ccp(120, -400) )
#define kHowToScorePosition          ADJUST_CCP_MAIN_SCENE( ccp(165, -620) )
#define kHowToCreditsHeaderPosition          ADJUST_CCP_MAIN_SCENE( ccp(165.00, -700) )
#define kHowToCreditsCopyPosition          ADJUST_CCP_MAIN_SCENE( ccp(165.00, -738) )
//Level scene
#define kLevelCodeBasePosition      ADJUST_CCP( ccp(133, 455) )
#define kLevelBasePosition          ADJUST_CCP_LEVEL_BASE( ccp(0, 0) )
#define kLevelRotorRightPosition    ADJUST_CCP( ccp(259.00, 434.00) )
#define kLevelRotorLeftPosition     ADJUST_CCP( ccp(54.00, 430.00) )
#define kLevelSphereLightPosition   ADJUST_CCP( ccp(150.00, 411.00) )
#define kLevelMantlePosition        ADJUST_CCP( ccp(160.00, 456.00) )
#define kLevelSpherePosition        ADJUST_CCP( ccp(152, 474) )

#define kScorePanelInPosition      ADJUST_CCP( ccp(102.00, 220.00) )
#define kScorePanelOutPosition     ADJUST_CCP( ccp(-720.00, 0.00) )
#define kReplayPanelInPosition      ADJUST_CCP( ccp(225.50, 235.00) )
#define kReplayPanelOutPosition     ADJUST_CCP( ccp(1000.00, 367.00) )
#define kGameMenuPanelInPosition      ADJUST_CCP( ccp(100.00, 161.00) )
#define kGameMenuPanelOutPosition     ADJUST_CCP( ccp(-700.00, 0.00) )
#define kContinuePanelInPosition      ADJUST_CCP( ccp(225.50, 235.00) )
#define kContinuePanelOutPosition     ADJUST_CCP( ccp(1000.00, 367.00) )

//Settings scene
#define kSettingsScoreItemPosition   ADJUST_CCP( ccp(56.50, 377.50) )
#define kSettingsCareerItemPosition  ADJUST_CCP( ccp(56.50, 323.50) )
#define kSettingsMusicSliderPosition ADJUST_CCP( ccp(180, 252) )
#define kSettingsSoundSliderPosition ADJUST_CCP( ccp(180, 213) )
#define kSettingsRedLightPosition    ADJUST_CCP( ccp(61, 323.50) )
#define kSettingsSmokeParticlePosition ADJUST_CCP( ccp(90, 520) )
//Score scene
#define kScoreBluePincl (IS_IPAD() == YES ? ccp(0, 346.00) : ccp(25, 346.00))
//Career scene
#define kCareerInfoPanel ADJUST_CCP( ccp(-850.00, 0.00) )
#define kCareerStartBulbon ADJUST_CCP_OFFSET2( ccp(359.5, 222) )
#define kCareerMinScale (IS_IPAD() == YES ? 0.8533 : 0.8)
#define kCareerPanelInPosition      ADJUST_CCP_MAIN_SCENE( ccp(125.00, 98.00) )
#define kCareerPanelOutPosition      ADJUST_CCP_MAIN_SCENE( ccp(-850.00, 0.00) )


/* ANIMATIONS */
//Main scene
#define kMainLogoShadowMoveLeft     ADJUST_CCP_MAIN_SCENE( ccp(kScreenCenterX - 5, kScreenCenterY + 162) )
#define kMainLogoShadowMoveRight    ADJUST_CCP_MAIN_SCENE( ccp(kScreenCenterX + 5, kScreenCenterY + 162) )

/* TEXTURE FILES */
#define kThunderboltsTexture SD_OR_HD(@"Lightning.plist")
//Video
#define kFlowVideo SDVIDEO_OR_HDVIDEO(@"Flow_video")
//Main scene
#define kMainMainTexture SD_OR_HD(@"Main.plist")
#define kMainHqTexture   SD_OR_HD(@"Hq.plist")
//HowTo scene
#define kHowToTexture   SD1_OR_HD1(@"Howto.plist")
//Level scene
#define kLevelBgTexture SD_OR_HD(@"LevelBg.plist")
#define kLevelAnimationsTexture SD_OR_HD(@"Animations.plist")
#define kLevelLevelTexture SD_OR_HD(@"Level.plist")
#define kLevelLevelPvr SDPVR_OR_HDPVR(@"Animations.pvr.ccz")
#define kThunderboltPvr SDPVR_OR_HDPVR(@"Lightning.pvr.ccz")
//Settings
#define kSettingsTexture   SD_OR_HD(@"Settings.plist")
//Score
#define kScoreTexture   SD_OR_HD(@"score.plist")
//Career
//#define kCareerTexture   SD1_OR_HD1(@"Career.plist")
#define kCareerTexture   SD_OR_HD(@"Career.plist")
#define kCareerHqTexture   SD_OR_HD(@"CareerHq.plist")
//Loader
#define kLoaderTexture   SD1_OR_HD1(@"Loader.plist")

/* PARTICLES */
#define kMainRainParticle SD_OR_HD(@"rain.plist")
#define kDustParticle SD_OR_HD(@"dust.plist")
#define kSmokeParticle SD_OR_HD(@"smoke2.plist")
#define kSmokeSmallParticle SD_OR_HD(@"smokeSmall.plist")
#define kVyronParticle SD_OR_HD(@"vyron.plist")
#define kPinDustParticle SD_OR_HD(@"pin_dust.plist")
#define kConfirmParticle SD_OR_HD(@"confirm.plist")


