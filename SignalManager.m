//
//  SignalManager.m
//  SmartIR
//
//  Created by FoolishTreeCat on 14-8-15.
//  Copyright (c) 2014年 FoolishTreeCat. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "SignalManager.h"
#import "Signal.h"

#define SAMPLE_RATE 44100
#define FREQUENCY 19000
#define MAX_VALUE 8192 // caution: signal should not be too strong, max is 32767(2^16)

@interface SignalManager() {
    SInt8 genSignal[4096];
    SInt8 genSpace[4096];
}

@property (strong, nonatomic) AVAudioSession *audioSession;
@property (strong, nonatomic) NSMutableArray *signalSpaceList;
@property (nonatomic) AudioComponentInstance toneUnit;

@property SInt8* genSignal;
@property SInt8* genSpace;
@property BOOL isInit;

@end

@implementation SignalManager

-(instancetype)init
{
    self = [super init];
    self.audioSession = [AVAudioSession sharedInstance];
    NSError *nsError;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&nsError];
    //[self addObserver:self forKeyPath:@"" options:0 context:nil];
    self.isInit = false;
    return self;
}

-(SInt8 *)genSignal
{
    return genSignal;
}

-(void)setGenSignal:(SInt8 *)enSignal
{
    if (enSignal != NULL) {
        for (int i = 0; i < 4096; i++) {
            genSignal[i] = enSignal[i];
        }
    }
}

-(SInt8 *)genSpace
{
    return genSpace;
}

-(void)setGenSpace:(SInt8 *)enSpace
{
    if (enSpace != NULL) {
        for (int i = 0; i < 4096; i++) {
            genSpace[i] = enSpace[i];
        }
    }
}

-(void)start
{
    if (self.isInit) {
        return;
    }
    
    [self.audioSession setActive:true error:nil];
    [self initSignal];
    [self createToneUnit];
}

-(void)initSignal
{
    for (UInt32 frame = 0; frame < 4096;) {
        double dVal = sin(2 * M_PI * ((double)frame) / 4.0 / (((double)SAMPLE_RATE) / ((double)FREQUENCY)));
        SInt16 val = (SInt16)(dVal * MAX_VALUE);
        SInt16 valMinu = (SInt16)-val;
        // in 16 bit wav PCM, first byte is the low order byte
        genSpace[frame] = 0;
        genSignal[frame++] = (SInt8)(val & 0x00FF);
        genSpace[frame] = 0;
        genSignal[frame++] = (SInt8)(((UInt16)(val & 0xFF00)) >> 8);
        genSpace[frame] = 0;
        genSignal[frame++] = (SInt8)(valMinu & 0x00FF);
        genSpace[frame] = 0;
        genSignal[frame++] = (SInt8)(((UInt16)(valMinu & 0xFF00)) >> 8);
    }
}

-(void)sendSignal:(NSArray *)signalSpaceList
{
    if (!self.isInit) {
        return;
    }
    self.signalSpaceList = [NSMutableArray arrayWithArray:signalSpaceList];
    
//    for (int i = 0; i < self.signalSpaceList.count; i++) {
//        Signal *signal = [self.signalSpaceList objectAtIndex:i];
//        NSLog(@"signal.length: %d, isSignal: %d", signal.length, signal.isSignal);
//    }
    
    //start
    AudioOutputUnitStart(_toneUnit);
}

-(void)pause
{
    AudioOutputUnitStop(self.toneUnit);
}

-(void)stop
{
    if (self.toneUnit) {
        AudioOutputUnitStop(self.toneUnit);
        AudioUnitUninitialize(self.toneUnit);
        AudioComponentInstanceDispose(self.toneUnit);
        self.toneUnit = nil;
    }
    
    [self.audioSession setActive:false error:nil];
    self.isInit = false;
}

-(void)createToneUnit
{
    // Configure the search parameters to find the default playback output unit
    // (called the kAudioUnitSubType_RemoteIO on iOS but
    // kAudioUnitSubType_DefaultOutput on Mac OS X)
    AudioComponentDescription defaultOutputDescription;
    defaultOutputDescription.componentType = kAudioUnitType_Output;
    defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    defaultOutputDescription.componentFlags = 0;
    defaultOutputDescription.componentFlagsMask = 0;
    
    // Get the default playback output unit
    AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
    NSAssert(defaultOutput, @"Can't find default output");
    
    // Create a new unit based on this that we'll use for output
    OSErr error = AudioComponentInstanceNew(defaultOutput, &_toneUnit);
    
    // Set our tone rendering function on the unit
    AURenderCallbackStruct input;
    input.inputProc = RenderTone;
    input.inputProcRefCon = (__bridge void *)self;
    error = AudioUnitSetProperty(self.toneUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &input, sizeof(input));
    
    const int four_bytes_per_float = 4;
    const int eight_bits_per_byte = 8;
    AudioStreamBasicDescription streamFormat;
    streamFormat.mSampleRate = SAMPLE_RATE;
    streamFormat.mFormatID = kAudioFormatLinearPCM;
    streamFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved;
    streamFormat.mBytesPerPacket = four_bytes_per_float;
    streamFormat.mFramesPerPacket = 1;
    streamFormat.mBytesPerFrame = four_bytes_per_float;
    streamFormat.mChannelsPerFrame = 2;
    streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
    error = AudioUnitSetProperty(self.toneUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &streamFormat, sizeof(streamFormat));
    
    self.isInit = true;
}

OSStatus RenderTone(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    //NSLog(@"RenderTone come in");
    int audio_length = inNumberFrames * 4;
    
    SInt8 *buffer0 = (SInt8 *)ioData->mBuffers[0].mData;
    SInt8 *buffer1 = (SInt8 *)ioData->mBuffers[1].mData;
    
    SignalManager *signalManager = (__bridge SignalManager *)inRefCon;
    NSMutableArray *array = signalManager->_signalSpaceList;
    SInt8 *genSignal = signalManager->genSignal;
    SInt8 *genSpace = signalManager->genSpace;
    
    //int array_count = (int)array.count;
    //NSLog(@"array_count: %d", array_count);
    //if (array_count <= 0) { // invalid array
        //buffer0 = 0;
        //buffer1 = 0;
        
        //[signalManager pause];
        
        //return noErr;
    //}
    
    //NSLog(@"RenderTone midlle");
    for (int i = 0; i < audio_length;) {
        if (array.count <= 0) { // caution: avoid array out of index
            if (i < audio_length) {
                memcpy(buffer0 + i, genSpace, audio_length - i);
                memcpy(buffer1 + i, genSpace, audio_length - i);
            }
            
            [signalManager pause];
            break;
        }
        Signal *signal = [array objectAtIndex:0];
        if (i + signal.length < audio_length) {
            if (signal.isSignal) {
                //NSLog(@"signal.length_signal: %d", signal.length);
                memcpy(buffer0 + i, genSignal, signal.length);
                memcpy(buffer1 + i, genSignal, signal.length);
            } else {
                //NSLog(@"signal.length_space: %d", signal.length);
                memcpy(buffer0 + i, genSpace, signal.length);
                memcpy(buffer1 + i, genSpace, signal.length);
            }
            i += signal.length;
            [array removeObjectAtIndex:0];
        } else {
            if (signal.isSignal) {
                //NSLog(@"audio_length - i_signal: %d", audio_length - i);
                memcpy(buffer0 + i, genSignal, audio_length - i);
                memcpy(buffer1 + i, genSignal, audio_length - i);
            } else {
                //NSLog(@"audio_length - i_space: %d", audio_length - i);
                memcpy(buffer0 + i, genSpace, audio_length - i);
                memcpy(buffer1 + i, genSpace, audio_length - i);
            }
            signal.length -= (audio_length - i);
            break;
        }
    }
    
    //NSLog(@"RenderTone go out");
    
    return noErr;
}

@end