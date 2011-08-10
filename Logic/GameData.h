//
//  GameData.h
//  Logic
//
//  Created by Pavel Krusek on 7/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "Figure.h"

@interface GameData : NSObject {

FMDatabase *db;
FMResultSet *rs;
    
}

- (void) writeScore:(int)score andDifficulty:(int)diff;
- (NSMutableArray *) getScores:(int)diff;
- (int) getMaxScore:(int)diff;

- (void) updateSettingsWithDifficulty:(int)diff andMusicLevel:(float)music andSoundLevel:(float)sound;
- (settings) getSettings;

//truncate game data tables
- (void) gameDataCleanup;

- (BOOL) isActiveGame;

//write game data
- (void) insertGameData:(gameInfo)data;
- (void) insertDeadFigure:(deadFigure)figure;
- (void) insertRow:(gameRow)row;

//read game data
- (gameInfo) getGameData;
- (NSMutableArray *) getDeadFigures;
- (NSMutableArray *) getRows;

//write career
- (void) insertCareerData:(int)city;
- (void) updateCareerData:(BOOL)flag;

//read career
- (NSMutableArray *) getCareerData;

//delete career
- (void) resetCareer;


@end
