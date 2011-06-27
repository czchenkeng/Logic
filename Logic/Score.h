//
//  Score.h
//  Logic
//
//  Created by Pavel Krusek on 6/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Score : NSObject {
    NSString *uniqueId;
    NSString *score;
    NSString *time;
    NSString *date;
}

@property (nonatomic, copy, readwrite) NSString *uniqueId;
@property (nonatomic, copy, readwrite) NSString *score;
@property (nonatomic, copy, readwrite) NSString *time;
@property (nonatomic, copy, readwrite) NSString *date;


- (id)initWithUniqueId:(NSString *)uid score:(NSString *)lscore time:(NSString *)ltime date:(NSString *)ldate;

@end