//
//  ScoreLayer.m
//  Logic
//
//  Created by Pavel Krusek on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScoreLayer.h"


@implementation ScoreLayer

@synthesize scores;


- (void) getRecordsWithDifficulty:(int)diff {
    if (scores.count > 0) {
        [scores removeAllObjects];
        [controller removeScores];
    }

    
    rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM scores WHERE difficulty = %i ORDER BY score DESC", diff]];
    //rs = [db executeQuery:@"SELECT * FROM scores ORDER BY score DESC"];

    if ([db hadError]) {
        CCLOG(@"DB Error %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];  
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    int i = 1;
    while ([rs next]) {
        NSString *formattedOutput = [formatter stringFromNumber:[NSNumber numberWithInt:[rs intForColumn:@"score"]]];
//        CCLOG(@"id %@", [NSString stringWithFormat:@"%i.", i]);
//        CCLOG(@"score %@", [formattedOutput stringByReplacingOccurrencesOfString:@"," withString:@" "]);
//        CCLOG(@"time form select %@", [rs stringForColumn:@"time"]);
//        CCLOG(@"date form select %@", [rs stringForColumn:@"date"]);
//        CCLOG(@"========================================================");
        NSString *uid = [NSString stringWithFormat:@"%i.", i];
        NSString *score = [formattedOutput stringByReplacingOccurrencesOfString:@"," withString:@" "];
        NSString *time = [rs stringForColumn:@"time"];
        NSString *date = [rs stringForColumn:@"date"];
        Score *scoreObj = [[Score alloc] initWithUniqueId:uid score:score time:time date:date];                        
        [scores addObject:scoreObj];
        //[controller.scores addObject:scoreObj];
        [uid release];
        [score release];
        [time release];
        [date release];
        //[scoreObj release];
        i++;
    }
    //[rs close];
    //rs = nil;
    //[db commit];
    
    CCLOG(@"scores %@ %i", scores, scores.count);
    [formatter release];
    
    
    //[controller removeScores];
    //controller.scores = nil;
    controller.scores = scores;
//    for (Score *sc in scores) {
//        [controller.scores addObject:sc];
//    }
    CCLOG(@"controller scores count %i", controller.scores.count);

    //[controller.tableView beginUpdates];
    
    CCLOG(@"TABLE VIEW %@", controller.tableView);
    //[[controller.tableView dataSource] = scores;
    //NSArray *tempArray = [[NSArray alloc] initWithArray:scores copyItems:YES];
    //controller.tableView.dataSource = tempArray;

    [controller.tableView reloadData];
    //[controller.tableView setNeedsDisplay];
    
    CCLOG(@"jen tak");
//    NSString *query = @"SELECT * FROM scores WHERE difficulty = 4 ORDER BY score DESC";
//    sqlite3_stmt *statement;
//    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
//        while (sqlite3_step(statement) == SQLITE_ROW) {
//            int uniqueId = sqlite3_column_int(statement, 1);
//            char *cityChars = (char *) sqlite3_column_text(statement, 3);
//             NSString *date = [[NSString alloc] initWithUTF8String:cityChars];
//            CCLOG(@"a ted? %i", uniqueId);
//            CCLOG(@"a ted? %@", date);
//            //            char *nameChars = (char *) sqlite3_column_text(statement, 1);
//            //            char *cityChars = (char *) sqlite3_column_text(statement, 2);
//            //            char *stateChars = (char *) sqlite3_column_text(statement, 3);
//        }
//        //sqlite3_finalize(statement);
//    } else {
//        NSLog(@"wrong");
//    }
//    NSLog(@"OK");
}


- (void) buttonTapped:(CCMenuItem *)sender { 
    switch (sender.tag) {
        case kButtonBack:
            CCLOG(@"TAP ON BACK");
            [[GameManager sharedGameManager] runSceneWithID:kSettingsScene andTransition:kSlideInL];
            break;
        default:
            CCLOG(@"Logic debug: Unknown ID, cannot tap button");
            return;
            break;
    }
}

- (void) diffTapped:(CCMenuItem *)sender {
    int flag;
    switch (sender.tag) {
        case kEasy: 
            CCLOG(@"TAP ON EASY");
            joyStick.position = ccp(92.00, 135.00);
            flag = 0;
            break;
        case kMedium:
            CCLOG(@"TAP ON MEDIUM");
            joyStick.position = ccp(92.00, 92.00);
            flag = 1;
            break;
        case kHard:
            CCLOG(@"TAP ON HARD");
            joyStick.position = ccp(92.00, 49.00);
            flag = 2;
            break;
        default:
            CCLOG(@"Logic debug: Unknown ID, cannot tap button");
            return;
            break;
    }
    for (CCSprite *diffButton in difficulty) {
        diffButton.visible = NO; 
    }
    CCSprite *currentButton = [difficulty objectAtIndex:flag];
    currentButton.visible = YES;
    
    for (CCSprite *joy in joysticks) {
        joy.visible = NO; 
    }
    CCSprite *currentJoy = [joysticks objectAtIndex:flag];
    currentJoy.visible = YES;
    
    [self getRecordsWithDifficulty:sender.tag];
    //[GameManager sharedGameManager].currentDifficulty = sender.tag;
}

- (void)onEnter {
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

- (void)onExit {
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}

- (void) createEditableCopyOfDatabaseIfNeeded {
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"LogicDatabase.sqlite"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    CCLOG(@"success %i", success);
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"LogicDatabase.sqlite"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

- (id) init {
    self = [super init];
    if (self != nil) {
        
        [self createEditableCopyOfDatabaseIfNeeded];

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; 
        DBPath = [documentsDirectory stringByAppendingPathComponent:@"LogicDatabase.sqlite"];
        
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        [fileManager removeItemAtPath:writableDBPath error:NULL];
        
        
        CCLOG(@"dir %@", documentsDirectory);
        db = [[FMDatabase databaseWithPath:DBPath] retain];
        if (![db open]) {
            CCLOG(@"Could not open db.");
            [db setLogsErrors:TRUE];
            [db setTraceExecution:TRUE];
        } else {
            CCLOG(@"Db is here!");
        }
        
        //NSMutableArray *scores = [[[NSMutableArray alloc] init] autorelease];
        //scores = [[[NSMutableArray alloc] init] autorelease];
        scores = [[[NSMutableArray alloc] init] retain];
        
        CGRect frame = CGRectMake(40, 100, 240, 180);
        controller = [[ScoresListViewController alloc] init];
        
        UIView *tableContainer = [[UIView alloc] initWithFrame:frame];
        [tableContainer addSubview:controller.view];
        
        CCUIViewWrapper *tableWrapper = [CCUIViewWrapper wrapperForUIView:tableContainer];
        [self addChild:tableWrapper z:2];
        
        
//        NSString *docsDir;
//        NSArray *dirPaths;
//        
//        // Get the documents directory
//        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        
//        docsDir = [dirPaths objectAtIndex:0];
//        
//        // Build the path to the database file
//        databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"LogicDatabase.sqlite"]];
//        
//        NSFileManager *filemgr = [NSFileManager defaultManager];
//        
//        if ([filemgr fileExistsAtPath: databasePath ] == NO) {
//            CCLOG(@"NENI");
//        } else {
//            CCLOG(@"JE");
//            const char *dbpath = [databasePath UTF8String];
//            if (sqlite3_open(dbpath, &_database) == SQLITE_OK) {
//                CCLOG(@"OPEN");
//            }
//        }
        
//        NSString *sqLiteDb = [[NSBundle mainBundle] pathForResource:@"LogicDatabase.sqlite" 
//                                                             ofType:@"sqlite3"];
//        
//        if (sqlite3_open([sqLiteDb UTF8String], &_database) != SQLITE_OK) {
//            NSLog(@"Failed to open database!");
//        } else {
//            NSLog(@"open database! %@", _database);
//        }
        
        //rs = [FMResultSet 
        
//        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//        [dateFormat setDateFormat:@"d/M/yy"];
//        
//        NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
//        [timeFormat setDateFormat:@"h:ma"];
//        
//        NSDate *now = [[NSDate alloc] init];
//        
//        NSString *theDate = [dateFormat stringFromDate:now];
//        NSString *theTime = [timeFormat stringFromDate:now];
//        
//        NSLog(@"\n"
//              
//              "theDate: |%@| \n"
//              "theTime: |%@| \n"
//              , theDate, theTime);
//
//                
//        [db executeUpdate:@"INSERT INTO scores (score, difficulty, date, time) values (?, ?, ?, ?)", [NSNumber numberWithInt:22356789], [NSNumber numberWithInt:5], theDate, theTime];
//        [db executeUpdate:@"INSERT INTO scores (score, difficulty, date, time) values (?, ?, ?, ?)", [NSNumber numberWithInt:89213490], [NSNumber numberWithInt:4], theDate, theTime];
//        [db executeUpdate:@"INSERT INTO scores (score, difficulty, date, time) values (?, ?, ?, ?)", [NSNumber numberWithInt:99999999], [NSNumber numberWithInt:4], theDate, theTime];
//        [db executeUpdate:@"INSERT INTO scores (score, difficulty, date, time) values (?, ?, ?, ?)", [NSNumber numberWithInt:34567345], [NSNumber numberWithInt:6], theDate, theTime];
//        [db executeUpdate:@"INSERT INTO scores (score, difficulty, date, time) values (?, ?, ?, ?)", [NSNumber numberWithInt:12345678], [NSNumber numberWithInt:6], theDate, theTime];
//        [db executeUpdate:@"INSERT INTO scores (score, difficulty, date, time) values (?, ?, ?, ?)", [NSNumber numberWithInt:84848484], [NSNumber numberWithInt:5], theDate, theTime];
//        [db executeUpdate:@"INSERT INTO scores (score, difficulty, date, time) values (?, ?, ?, ?)", [NSNumber numberWithInt:22356789], [NSNumber numberWithInt:5], theDate, theTime];
//        [db executeUpdate:@"INSERT INTO scores (score, difficulty, date, time) values (?, ?, ?, ?)", [NSNumber numberWithInt:89213490], [NSNumber numberWithInt:4], theDate, theTime];
//        [db executeUpdate:@"INSERT INTO scores (score, difficulty, date, time) values (?, ?, ?, ?)", [NSNumber numberWithInt:99999999], [NSNumber numberWithInt:4], theDate, theTime];
//        [db executeUpdate:@"INSERT INTO scores (score, difficulty, date, time) values (?, ?, ?, ?)", [NSNumber numberWithInt:34567345], [NSNumber numberWithInt:6], theDate, theTime];
//        [db executeUpdate:@"INSERT INTO scores (score, difficulty, date, time) values (?, ?, ?, ?)", [NSNumber numberWithInt:12345678], [NSNumber numberWithInt:6], theDate, theTime];
//        [db executeUpdate:@"INSERT INTO scores (score, difficulty, date, time) values (?, ?, ?, ?)", [NSNumber numberWithInt:84848484], [NSNumber numberWithInt:5], theDate, theTime];
//        [db executeUpdate:@"INSERT INTO scores (score, difficulty, date, time) values (?, ?, ?, ?)", [NSNumber numberWithInt:22356789], [NSNumber numberWithInt:5], theDate, theTime];
//        [db executeUpdate:@"INSERT INTO scores (score, difficulty, date, time) values (?, ?, ?, ?)", [NSNumber numberWithInt:89213490], [NSNumber numberWithInt:4], theDate, theTime];
//        [db executeUpdate:@"INSERT INTO scores (score, difficulty, date, time) values (?, ?, ?, ?)", [NSNumber numberWithInt:99999999], [NSNumber numberWithInt:4], theDate, theTime];
//        [db executeUpdate:@"INSERT INTO scores (score, difficulty, date, time) values (?, ?, ?, ?)", [NSNumber numberWithInt:34567345], [NSNumber numberWithInt:6], theDate, theTime];
//        [db executeUpdate:@"INSERT INTO scores (score, difficulty, date, time) values (?, ?, ?, ?)", [NSNumber numberWithInt:12345678], [NSNumber numberWithInt:6], theDate, theTime];
//        [db executeUpdate:@"INSERT INTO scores (score, difficulty, date, time) values (?, ?, ?, ?)", [NSNumber numberWithInt:84848484], [NSNumber numberWithInt:5], theDate, theTime];
//        
//        [dateFormat release];
//        [timeFormat release];
//        [now release];
        
        
        difficulty = [[CCArray alloc] init];
        joysticks = [[CCArray alloc] init];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"score.plist"];
        
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"background.png"];
        background.anchorPoint = ccp(0,0);
        [self addChild:background z:1];
        
        
        CCSprite *buttonBackOff = [CCSprite spriteWithSpriteFrameName:@"back_off.png"];
        CCSprite *buttonBackOn = [CCSprite spriteWithSpriteFrameName:@"back_on.png"];
        
        CCMenuItem *backItem = [CCMenuItemSprite itemFromNormalSprite:buttonBackOff selectedSprite:buttonBackOn target:self selector:@selector(buttonTapped:)];
        backItem.tag = kButtonBack;
        backItem.position = ccp(29.50, 453.50);
        
        CCMenu *topMenu = [CCMenu menuWithItems:backItem, nil];
        topMenu.position = CGPointZero;
        [self addChild:topMenu z:3];
        
        joyStick = [CCSprite spriteWithSpriteFrameName:@"paka_empty.png"];
        CCSprite *joyEasy = [CCSprite spriteWithSpriteFrameName:@"paka_1.png"];
        CCSprite *joyNormal = [CCSprite spriteWithSpriteFrameName:@"paka_2.png"];
        CCSprite *joyHard = [CCSprite spriteWithSpriteFrameName:@"paka_3.png"];
        joyEasy.anchorPoint = ccp(0, 0);
        joyNormal.anchorPoint = ccp(0, 0);
        joyHard.anchorPoint = ccp(0, 0);
        [joyStick addChild:joyEasy z:1];
        [joyStick addChild:joyNormal z:2];
        [joyStick addChild:joyHard z:3];
        [self addChild:joyStick z:5];
        [joysticks addObject:joyEasy];
        [joysticks addObject:joyNormal];
        [joysticks addObject:joyHard];
        
        CCSprite *sprite;
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"logik_easy1.png"];
        sprite.position = ccp(210.50, 138.50);
        [self addChild:sprite z:6 tag:6];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"logik_hard1.png"];
        sprite.position = ccp(210.50, 52.00);
        [self addChild:sprite z:7 tag:7];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"logik_normal1.png"];
        sprite.position = ccp(210.50, 95.00);
        [self addChild:sprite z:8 tag:8];
        
        easy = [[[CCSprite alloc] init] autorelease];
        normal = [[[CCSprite alloc] init] autorelease];
        hard = [[[CCSprite alloc] init] autorelease];
        [self addChild:easy z:9];
        [self addChild:normal z:10];
        [self addChild:hard z:11];
        easy.visible = NO;
        normal.visible = NO;
        hard.visible = NO;
        [difficulty addObject:easy];
        [difficulty addObject:normal];
        [difficulty addObject:hard];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"logik_easy2.png"];
        sprite.position = ccp(210.50, 138.50);
        [easy addChild:sprite z:1];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"dioda.png"];
        sprite.position = ccp(166.00, 141.00);
        [easy addChild:sprite z:2];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"logik_normal2.png"];
        sprite.position = ccp(210.50, 95.00);
        [normal addChild:sprite z:1];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"dioda.png"];
        sprite.position = ccp(166.00, 97.50);
        [normal addChild:sprite z:2];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"logik_hard2.png"];
        sprite.position = ccp(210.50, 52.00);
        [hard addChild:sprite z:1];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"dioda.png"];
        sprite.position = ccp(165.50, 53.50);
        [hard addChild:sprite z:2];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"pin_lezi3.png"];
        sprite.position = ccp(316.00, 243.50);
        sprite.rotation = -5;
        [self addChild:sprite z:100];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"pin_lezi2.png"];
        //sprite.position = ccp(23.50, 346.00);
        sprite.position = ccp(10, 346.00);
        [self addChild:sprite z:101];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"pin_lezi1.png"];
        sprite.position = ccp(306.50, 17.00);
        [self addChild:sprite z:102];
        
        CCSprite *buttonEasyOff = [CCSprite spriteWithSpriteFrameName:@"difficultyButton.png"];
        CCSprite *buttonEasyOn = [CCSprite spriteWithSpriteFrameName:@"difficultyButton.png"];
        CCSprite *buttonNormalOff = [CCSprite spriteWithSpriteFrameName:@"difficultyButton.png"];
        CCSprite *buttonNormalOn = [CCSprite spriteWithSpriteFrameName:@"difficultyButton.png"];
        CCSprite *buttonHardOff = [CCSprite spriteWithSpriteFrameName:@"difficultyButton.png"];
        CCSprite *buttonHardOn = [CCSprite spriteWithSpriteFrameName:@"difficultyButton.png"];
        
        easyItem = [CCMenuItemSprite itemFromNormalSprite:buttonEasyOff selectedSprite:buttonEasyOn target:self selector:@selector(diffTapped:)];
        easyItem.tag = kEasy;
        easyItem.position = ccp(205.00, 139.00);
        
        normalItem = [CCMenuItemSprite itemFromNormalSprite:buttonNormalOff selectedSprite:buttonNormalOn target:self selector:@selector(diffTapped:)];
        normalItem.tag = kMedium;
        normalItem.position = ccp(205.00, 95.50);
        
        hardItem = [CCMenuItemSprite itemFromNormalSprite:buttonHardOff selectedSprite:buttonHardOn target:self selector:@selector(diffTapped:)];
        hardItem.tag = kHard;
        hardItem.position = ccp(205.00, 53.00);
        
        PressMenu *difficultyMenu = [PressMenu menuWithItems:easyItem, normalItem, hardItem, nil];
        //CCMenu *difficultyMenu = [CCMenu menuWithItems:easyItem, normalItem, hardItem, nil];
        difficultyMenu.position = CGPointZero;
        [self addChild:difficultyMenu z:20];
        
        
        switch ([[GameManager sharedGameManager] currentDifficulty]) {
            case kEasy: 
                [easyItem activate];
                break;
            case kMedium:
                [normalItem activate];
                break;
            case kHard:
                [hardItem activate];
                break; 
        }

    }
    return self;
}

- (void) selectJoystick:(CGPoint)touchLocation {
    CCSprite *newSprite = nil;
    
    if (CGRectContainsPoint(joyStick.boundingBox, touchLocation)) {            
        newSprite = joyStick;
    }
    selJoystick = newSprite;
}


- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    [self selectJoystick:touchLocation];
    
    touchOrigin = [touch locationInView:[touch view]];
	touchOrigin = [[CCDirector sharedDirector] convertToGL:touchOrigin];
    return YES;
}

- (void) ccTouchEnded: (UITouch *)touch withEvent: (UIEvent *)event {
    if (selJoystick) {
        touchStop = [touch locationInView:[touch view]];
        touchStop = [[CCDirector sharedDirector] convertToGL:touchStop];
        float deltaY = touchStop.y - touchOrigin.y;
        
        if (fabs(deltaY) > 20) {
            if(deltaY < 0) {
                if ([[GameManager sharedGameManager] currentDifficulty] < 6) {
                    [GameManager sharedGameManager].currentDifficulty += 1;
                } 
            }//down
            else if (deltaY > 0){
                if ([[GameManager sharedGameManager] currentDifficulty] > 4) {
                    [GameManager sharedGameManager].currentDifficulty -= 1;
                }
            }
        }
        
        switch ([[GameManager sharedGameManager] currentDifficulty]) {
            case kEasy: 
                [easyItem activate];
                break;
            case kMedium:
                [normalItem activate];
                break;
            case kHard:
                [hardItem activate];
                break; 
        }
    }
}

- (void) dealloc {
    CCLOG(@"Logic debug: %@: %@", NSStringFromSelector(_cmd), self);
    [scores release];
    scores = nil;
    [db close];
    [db release];    
    //[rs close];
    //[rs release];
    //rs = nil;
    //[DBPath release];
    //DBPath = nil;
    [difficulty release];
    difficulty = nil;
    [joysticks release];
    joysticks = nil;
    [controller release];
    controller = nil;
    [super dealloc];
}

@end
