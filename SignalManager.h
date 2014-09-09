//
//  SignalManager.h
//  SmartIR
//
//  Created by FoolishTreeCat on 14-8-15.
//  Copyright (c) 2014年 FoolishTreeCat. All rights reserved.
//

#ifndef SmartIR_SignalManager_h
#define SmartIR_SignalManager_h
#import <Foundation/Foundation.h>

@interface SignalManager : NSObject

-(instancetype)init;

-(void)sendSignal:(NSArray*)signalSpaceList;
-(void)start;
-(void)pause;
-(void)stop;

@end
#endif
