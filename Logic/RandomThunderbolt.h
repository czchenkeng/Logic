//
//  RandomThunderbold.h
//  Logic
//
//  Created by Apple on 10/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThunderboltVO.h"

@interface RandomThunderbolt : NSObject {
    NSMutableArray *tArray;
    NSMutableArray *rArray;
}

- (void) loadData:(int)diff;
- (void) loadFiguresData:(int)diff;
- (ThunderboltVO *) getThunderbolt:(int)activeRow;
- (NSMutableArray *) getRowData:(int)activeRow;

@end
