//
//  RandomThunderbold.m
//  Logic
//
//  Created by Apple on 10/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RandomThunderbolt.h"
#import "CJSONDeserializer.h"

@interface RandomThunderbolt (PrivateMethods)
- (NSString *) jsonFromFile:(NSString *)file;
- (void) handleError:(NSError *)error;
@end

@implementation RandomThunderbolt

- (id) init {
    self = [super init];
    if (self != nil) {
        tArray = [[NSMutableArray alloc] init];
        rArray  = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark -
#pragma mark Load thunderbolt data
- (void) loadData:(int)diff {
    NSString *jsonString = [self jsonFromFile:[NSString stringWithFormat:@"tData_%i",diff]];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    CJSONDeserializer *jsonDeserializer = [CJSONDeserializer deserializer];
    NSError *error = nil;
    NSDictionary *resultsDictionary = [jsonDeserializer deserializeAsDictionary:jsonData error:&error];
    [self handleError:error];
    NSArray *dataArray = [resultsDictionary objectForKey:@"thunderbolts"];
    ThunderboltVO *tVO;
    for (NSDictionary *cDictionary in dataArray) {
        tVO = [[ThunderboltVO alloc] init];
        tVO.startPos = ccp([[[cDictionary objectForKey:@"startPoint"] objectAtIndex:0] floatValue] -3, [[[cDictionary objectForKey:@"startPoint"] objectAtIndex:1] floatValue] + 17);
        tVO.endPos = ccp([[[cDictionary objectForKey:@"endPoint"] objectAtIndex:0] floatValue] -3, [[[cDictionary objectForKey:@"endPoint"] objectAtIndex:1] floatValue] + 17);
        tVO.row = [[cDictionary objectForKey:@"row"] intValue];
        tVO.type = [[cDictionary objectForKey:@"type"] intValue];
        tVO.typePos = [[cDictionary objectForKey:@"position"] intValue];
        [tArray addObject:tVO];
    }
}

#pragma mark -
#pragma mark Load figures data
- (void) loadFiguresData:(int)diff {
    NSString *jsonString = [self jsonFromFile:[NSString stringWithFormat:@"pos%i",diff]]; 
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    CJSONDeserializer *jsonDeserializer = [CJSONDeserializer deserializer];
    NSError *error = nil;
    NSDictionary *resultsDictionary = [jsonDeserializer deserializeAsDictionary:jsonData error:&error];
    [self handleError:error];
    NSArray *dataArray = [resultsDictionary objectForKey:@"positions"];
    ThunderboltVO *tVO;
    for (NSDictionary *cDictionary in dataArray) {
        tVO = [[ThunderboltVO alloc] init];
        tVO.startPos = ccp([[[cDictionary objectForKey:@"point"] objectAtIndex:0] floatValue] - 3, [[[cDictionary objectForKey:@"point"] objectAtIndex:1] floatValue] + 17);
        tVO.row = [[cDictionary objectForKey:@"row"] intValue];
        [rArray addObject:tVO];
    }
}

#pragma mark -
#pragma mark Get random thunderbolt
- (ThunderboltVO *) getThunderbolt:(int)activeRow {
    NSMutableArray *retVal = [[NSMutableArray alloc] init];
    for (ThunderboltVO *tVO in tArray) {
        if (tVO.row <= activeRow) {
            [retVal addObject:tVO];
        }
    }
    NSUInteger randomIndex = arc4random() % [retVal count];
    return [retVal objectAtIndex:randomIndex];
}

#pragma mark -
#pragma mark Get row
- (NSMutableArray *) getRowData:(int)activeRow {
    NSMutableArray *retVal = [[NSMutableArray alloc] init];
    for (ThunderboltVO *tVO in rArray) {
        if (tVO.row == activeRow + 1) {
            [retVal addObject:tVO];
        }
    }
    return retVal;
}


#pragma mark -
#pragma mark Data from file - helper method
- (NSString *) jsonFromFile:(NSString *)file {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:file ofType:@"json"];  
    NSData *myData = [NSData dataWithContentsOfFile:filePath];
    NSString *s = [[[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding] autorelease];    
    return s;
}

#pragma mark -
#pragma mark Error handlers
- (void) handleError:(NSError *)error {
    if (error != nil) {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [errorAlertView show];
        [errorAlertView release];
    }
}

- (void) dealloc {
    [tArray release];
    [rArray release];
    tArray = nil;
    rArray = nil;
    [super dealloc];
}

@end
