//
//  Signal.m
//  SmartIR
//
//  Created by FoolishTreeCat on 14-9-2.
//  Copyright (c) 2014年 FoolishTreeCat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Signal.h"

@implementation Signal

@synthesize length;
@synthesize isSignal;

-(instancetype)init:(int)value isSignal:(bool)flag
{
    self = [super init];
    if (self) {
        self.length = (int)(((double)(value * 44100) / 1000000.0) * 4);
        self.isSignal = flag;
    }
    return self;
}

@end