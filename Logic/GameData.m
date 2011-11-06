//
//  GameData.m
//  Logic
//
//  Created by Pavel Krusek on 7/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameData.h"



@implementation GameData

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
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
        
        [self createEditableCopyOfDatabaseIfNeeded];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; 
        NSString *DBPath = [documentsDirectory stringByAppendingPathComponent:@"LogicDatabase.sqlite"];
        
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        [fileManager removeItemAtPath:DBPath error:NULL];
        
        db = [[FMDatabase databaseWithPath:DBPath] retain];
        if (![db open]) {
            CCLOG(@"Could not open db.");
        } else {
            CCLOG(@"Db is here!");
            //[db setLogsErrors:TRUE];
            //[db setTraceExecution:TRUE];
        }
    }
    return self;
}

- (BOOL) isActiveGame {
    int totalCount = 0;
    rs = [db executeQuery:@"SELECT COUNT(*) FROM game_data"];
    if ([rs next]) {
        totalCount = [rs intForColumnIndex:0];
    }
    return totalCount == 0 ? NO : YES;
}

- (void) gameDataCleanup {
    [db beginTransaction];
    [db executeUpdate:@"DELETE FROM game_dead_figures"];
    [db executeUpdate:@"DELETE FROM game_active_figures"];
    [db executeUpdate:@"DELETE FROM game_data"];
    [db executeUpdate:@"DELETE FROM game_rows"];
    [db executeUpdate:@"DELETE FROM game_code"];
    [[GameManager sharedGameManager] deletePattern];
    [db commit];
}

- (void) updateSettingsWithDifficulty:(int)diff andMusicLevel:(float)music andSoundLevel:(float)sound {
    [db beginTransaction];
    [db executeUpdate:@"UPDATE game_settings SET difficulty = ?, music_level = ?, sound_level = ? WHERE id=1", [NSNumber numberWithInt:diff], [NSNumber numberWithFloat:music], [NSNumber numberWithFloat:sound]];
    [db commit];
}

- (void) updateSettingsWithTutor {
    [db beginTransaction];
    [db executeUpdate:@"UPDATE game_settings SET tutor = 0 WHERE id=1"];
    [db commit];
}

- (void) updateSettingsWithReview {
    [db beginTransaction];
    [db executeUpdate:@"UPDATE game_settings SET review = 0 WHERE id=1"];
    [db commit];
}

- (settings) getSettings {
    rs = [db executeQuery:@"SELECT * FROM game_settings WHERE id = 1"];
    settings retVal;
    while ([rs next]) {
        retVal.gameDifficulty = [rs intForColumn:@"difficulty"];
        retVal.musicLevel = [rs doubleForColumn:@"music_level"];
        retVal.soundLevel = [rs doubleForColumn:@"sound_level"];
        retVal.tutor = [rs intForColumn:@"tutor"];
        retVal.careerTutor = [rs intForColumn:@"career_tutor"];
        retVal.review = [rs intForColumn:@"review"];
    }
    return retVal;
}

- (void) insertGameData:(gameInfo)data {
    [db beginTransaction];
    [db executeUpdate:@"INSERT INTO game_data (difficulty, active_row, career, score, game_time, tutor) values (?, ?, ?, ?, ?, ?)", 
     [NSNumber numberWithInt:data.difficulty], [NSNumber numberWithInt:data.activeRow], [NSNumber numberWithInt:data.career], 
     [NSNumber numberWithInt:data.score], [NSNumber numberWithInt:data.gameTime], [NSNumber numberWithInt:data.tutor]];
    [db commit];
}

- (gameInfo) getGameData {
    gameInfo retVal;    
    rs = [db executeQuery:@"SELECT * FROM game_data ORDER BY id DESC LIMIT 1"];
    if ([rs next]) {
        retVal.difficulty = [rs intForColumn:@"difficulty"];
        retVal.activeRow = [rs intForColumn:@"active_row"];
        retVal.career = [rs intForColumn:@"career"];
        retVal.score = [rs intForColumn:@"score"];
        retVal.gameTime = [rs intForColumn:@"game_time"];
        retVal.tutor = [rs intForColumn:@"tutor"];
    }
    
    return retVal;
}

- (void) insertActiveFigure:(activeFigure)figure {
    [db beginTransaction];
    [db executeUpdate:@"INSERT INTO game_active_figures (fid, color, posX, posY, place) values (?, ?, ?, ?, ?)", 
     [NSNumber numberWithInt:figure.fid], [NSNumber numberWithInt:figure.color], [NSNumber numberWithFloat:figure.position.x], [NSNumber numberWithFloat:figure.position.y], [NSNumber numberWithFloat:figure.place]];
    [db commit];
}

- (NSMutableArray *) getActiveFigures {
    rs = [db executeQuery:@"SELECT * FROM game_active_figures"];
    NSMutableArray *retVal = [[NSMutableArray alloc] init];//release?
    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:[NSNumber numberWithInt:[rs intForColumn:@"fid"]] forKey:@"fid"]; 
        [dict setObject:[NSNumber numberWithInt:[rs intForColumn:@"color"]] forKey:@"color"];
        [dict setObject:[NSNumber numberWithInt:[rs doubleForColumn:@"posX"]] forKey:@"posX"];
        [dict setObject:[NSNumber numberWithInt:[rs doubleForColumn:@"posY"]] forKey:@"posY"];
        [dict setObject:[NSNumber numberWithInt:[rs doubleForColumn:@"place"]] forKey:@"place"];
        [retVal addObject:dict];
    }
    return retVal;
}

- (void) deleteActiveFigure:(int)place {
    [db beginTransaction];
    [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM game_active_figures WHERE place = %i", place]];
    [db commit];
}

- (void) deleteActiveFigures {
    [db beginTransaction];
    [db executeUpdate:@"DELETE FROM game_active_figures"];
    [db commit];
}

//- (void) updateActiveFigure:(int)oldPlace withPlace:(int)newPlace andPosition:(CGPoint)pos {
//    [db beginTransaction];
//    [db executeUpdate:[NSString stringWithFormat:@"UPDATE game_active_figures SET place = %i, posX = %f, posY = %f WHERE place=%i", newPlace, pos.x, pos.y, oldPlace]];
//    [db commit];
//}

- (void) updateActiveFigure:(int)fid withPlace:(int)newPlace andPosition:(CGPoint)pos {
    [db beginTransaction];
    [db executeUpdate:[NSString stringWithFormat:@"UPDATE game_active_figures SET place = %i, posX = %f, posY = %f WHERE fid=%i", newPlace, pos.x, pos.y, fid]];
    [db commit];
}

- (void) updateActiveFigurePosition:(int)place andPosition:(CGPoint)pos {
    [db beginTransaction];
    [db executeUpdate:[NSString stringWithFormat:@"UPDATE game_active_figures SET posX = %f, posY = %f WHERE fid=%i", pos.x, pos.y, place]];
    [db commit];
}

- (void) insertDeadFigure:(deadFigure)figure {
    [db beginTransaction];
    [db executeUpdate:@"INSERT INTO game_dead_figures (color, posX, posY) values (?, ?, ?)", [NSNumber numberWithInt:figure.color], [NSNumber numberWithFloat:figure.position.x], [NSNumber numberWithFloat:figure.position.y]];
    [db commit];
}

- (NSMutableArray *) getDeadFigures {
    rs = [db executeQuery:@"SELECT * FROM game_dead_figures"];
    NSMutableArray *retVal = [[NSMutableArray alloc] init];//release?
    while ([rs next]) {
        Figure *figure = [[Figure alloc] initWithFigureType:[rs intForColumn:@"color"]];
        figure.tempPosition = ccp([rs doubleForColumn:@"posX"], [rs doubleForColumn:@"posY"]);
        [retVal addObject:figure];
    }
    return retVal;
}

- (void) insertRow:(gameRow)row {
    [db beginTransaction];
    [db executeUpdate:@"INSERT INTO game_rows (row, places, colors) values (?, ?, ?)", [NSNumber numberWithInt:row.row], [NSNumber numberWithInt:row.places], [NSNumber numberWithInt:row.colors]];
    [db commit];
}

- (NSMutableArray *) getRows {
    rs = [db executeQuery:@"SELECT * FROM game_rows"];
    NSMutableArray *retVal = [[NSMutableArray alloc] init];//release?
    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:[NSNumber numberWithInt:[rs intForColumn:@"row"]] forKey:@"row"];
        [dict setObject:[NSNumber numberWithInt:[rs intForColumn:@"places"]] forKey:@"places"];
        [dict setObject:[NSNumber numberWithInt:[rs intForColumn:@"colors"]] forKey:@"colors"];
        [retVal addObject:dict];
    }
    return retVal;
}

- (void) insertCode:(int)code {
    [db beginTransaction];
    [db executeUpdate:@"INSERT INTO game_code (color) values (?)", [NSNumber numberWithInt:code]];
    [db commit];
}

- (NSMutableArray *) getCode {
    NSMutableArray *retVal = [[NSMutableArray alloc] init];   
    rs = [db executeQuery:@"SELECT * FROM game_code"];
    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:[NSNumber numberWithInt:[rs intForColumn:@"color"]] forKey:@"color"];
        [retVal addObject:dict];
    }
    return retVal;
}

- (void) writeScore:(int)score andDifficulty:(int)diff {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d/M/yy"];
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"h:ma"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [timeFormat setLocale:usLocale];
    NSDate *now = [[NSDate alloc] init];       
    NSString *theDate = [dateFormat stringFromDate:now];
    NSString *theTime = [timeFormat stringFromDate:now];
    [db beginTransaction];         
    [db executeUpdate:@"INSERT INTO scores (score, difficulty, date, time) values (?, ?, ?, ?)", [NSNumber numberWithInt:score], [NSNumber numberWithInt:diff], theDate, theTime];
    [db commit];
    
    [dateFormat release];
    [timeFormat release];
    [now release];
}

- (void) writeCareerTutor {
    [db beginTransaction];
    [db executeUpdate:@"UPDATE game_settings SET career_tutor = 0 WHERE id=1"];
    [db commit];
}

- (void) insertCareerData:(int)city xPos:(float)xPos yPos:(float)yPos {
    [db beginTransaction];
    [db executeUpdate:@"INSERT INTO career (city, is_done, lastPosX, lastPosY, last_city, score) values (?, ?, ?, ?, ?, ?)", [NSNumber numberWithInt:city], [NSNumber numberWithInt:0], [NSNumber numberWithFloat:xPos], [NSNumber numberWithFloat:yPos], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0]];
    [db commit];
}

- (void) updateCareerData:(BOOL)flag andScore:(int)score{
    if (flag) {//career success
        [db beginTransaction];
        //[db executeUpdate:@"UPDATE career SET is_done = 1, score =  WHERE is_done=0"];
        [db executeUpdate:[NSString stringWithFormat:@"UPDATE career SET is_done = 1, score = %i WHERE is_done=0", score]];
        [db commit];
    } else {
        [db beginTransaction];
        [db executeUpdate:@"DELETE FROM career WHERE is_done = 0"];
        [db commit];
    }
}

- (void) updateCarrerLastCity {
    [db beginTransaction];
    [db executeUpdate:@"UPDATE career SET last_city = 1 WHERE last_city=0"];
    [db commit];
}

- (NSMutableArray *) getCareerData {
    rs = [db executeQuery:@"SELECT COUNT(*) FROM career"];
    if ([rs next]) {
        CCLOG(@"total count career is %i", [rs intForColumnIndex:0]);
    }
    
    //rs = [db executeQuery:@"SELECT * FROM career WHERE is_done=1 ORDER BY id ASC"];
    rs = [db executeQuery:@"SELECT * FROM career WHERE last_city=1 ORDER BY id ASC"];
    NSMutableArray *retVal = [[NSMutableArray alloc] init];//release?
    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:[NSNumber numberWithInt:[rs intForColumn:@"city"]] forKey:@"city"];
        [dict setObject:[NSNumber numberWithInt:[rs intForColumn:@"score"]] forKey:@"score"];
        [dict setObject:[NSNumber numberWithFloat:[rs doubleForColumn:@"lastPosX"]] forKey:@"posX"];
        [dict setObject:[NSNumber numberWithFloat:[rs doubleForColumn:@"lastPosY"]] forKey:@"posY"];
        [retVal addObject:dict];
    }
    return retVal;
}

- (city) getCityInProgress {
    city retVal;
    retVal.idCity = 0;
    rs = [db executeQuery:@"SELECT * FROM career WHERE is_done=0"];
    if ([rs next]) {
        //retVal.idCity = [[NSNumber numberWithInt:[rs intForColumn:@"city"]] intValue];
        retVal.idCity = [rs intForColumn:@"city"];
        retVal.position = ccp([rs doubleForColumn:@"lastPosX"], [rs doubleForColumn:@"lastPosY"]);
    }
    return retVal;
}

- (city) getLastCity {
    city retVal;
    retVal.idCity = 0;
    rs = [db executeQuery:@"SELECT * FROM career WHERE is_done=1 AND last_city = 0"];
    if ([rs next]) {
        retVal.idCity = [rs intForColumn:@"city"];
        retVal.score = [rs intForColumn:@"score"];
        retVal.position = ccp([rs doubleForColumn:@"lastPosX"], [rs doubleForColumn:@"lastPosY"]);
    }
    return retVal;
}

- (void) resetCareer {
    [db beginTransaction];
    [db executeUpdate:@"DELETE FROM career"];
    [db commit];
}

- (int) getMaxScore:(int)diff {
    rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM scores WHERE difficulty = %i ORDER BY score DESC LIMIT 1", diff]];
    
    int retVal;
    if ([rs next]) {
        retVal = [rs intForColumn:@"score"];
    } else {
        retVal = 0;
    }
    
    return retVal;
}

- (int) getNumScores {
    FMResultSet *s = [db executeQuery:@"SELECT COUNT(*) FROM scores"];
    int totalCount;
    if ([s next]) {
        totalCount = [s intForColumnIndex:0];
    }else{
        totalCount = 0;
    }
    //rs = [db executeQuery:@"SELECT count(id) FROM scores"];    
    //int retVal = [rs intForColumn:@"id"];
    
    return totalCount;
}

- (NSMutableArray *) getScores:(int)diff {    
    rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM scores WHERE difficulty = %i ORDER BY score DESC LIMIT 15", diff]];
    if ([db hadError]) {
        CCLOG(@"DB Error %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];  
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSMutableArray *retVal = [[NSMutableArray alloc] init];//release?
    
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
        [retVal addObject:scoreObj];
//        [uid release];
//        [score release];
//        [time release];
//        [date release];
        //[scoreObj release];
        i++;
    }
    [formatter release];
    
    return retVal;
}

- (void) dealloc {
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    [db release];
    [super dealloc];
}

@end