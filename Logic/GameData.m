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
            [db setLogsErrors:TRUE];
            [db setTraceExecution:TRUE];
        } else {
            CCLOG(@"Db is here!");
        }

    }
    return self;
}

- (void) updateSettingsWithDifficulty:(int)diff andMusicLevel:(float)music andSoundLevel:(float)sound {
    [db beginTransaction];
    [db executeUpdate:@"UPDATE game_settings SET difficulty = ?, music_level = ?, sound_level = ? WHERE id=1", [NSNumber numberWithInt:diff], [NSNumber numberWithFloat:music], [NSNumber numberWithFloat:sound]];
    [db commit];
}

- (settings) getSettings {
    rs = [db executeQuery:@"SELECT * FROM game_settings WHERE id = 1"];
    settings retVal;
    while ([rs next]) {
        retVal.gameDifficulty = [rs intForColumn:@"difficulty"];
        retVal.musicLevel = [rs doubleForColumn:@"music_level"];
        retVal.soundLevel = [rs doubleForColumn:@"sound_level"];
    }
    return retVal;
}

- (void) insertDeadFigure:(deadFigure)figure {
    
}

- (void) writeScore:(int)score andDifficulty:(int)diff {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d/M/yy"];
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"h:ma"];
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

- (NSMutableArray *) getScores:(int)diff {
    rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM scores WHERE difficulty = %i ORDER BY score DESC", diff]];
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
    
    [formatter release];
    
    return retVal;
}

@end
