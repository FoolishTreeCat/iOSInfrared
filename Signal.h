//
//  Signal.h
//  SmartIR
//
//  Created by FoolishTreeCat on 14-9-2.
//  Copyright (c) 2014年 FoolishTreeCat. All rights reserved.
//

#ifndef SmartIR_Signal_h
#define SmartIR_Signal_h
#import <Foundation/Foundation.h>

@interface Signal : NSObject

@property int length;
@property bool isSignal; //signal or space

-(instancetype)init:(int)value isSignal:(bool)flag;
@end

#endif
