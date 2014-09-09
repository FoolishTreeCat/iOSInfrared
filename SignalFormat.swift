//
//  SignalFormat.swift
//  SmartIR
//
//  Created by FoolishTreeCat on 14-9-2.
//  Copyright (c) 2014年 FoolishTreeCat. All rights reserved.
//

import Foundation

class SignalFormat : NSObject {
    
    class var sharedInstance: SignalFormat {
        struct Static {
            static let instance: SignalFormat = SignalFormat()
        }
        return Static.instance
    }
    
    /* nec protocol head */
    let head_h: Int32 = 9000
    let head_l: Int32 = 4500
    
    /* nec protocol value 1 */
    let one_h: Int32 = 560
    let one_l: Int32 = 1690
    
    /* nec protocol value 0 */
    let zero_h: Int32 = 560
    let zero_l: Int32 = 560
    
    let digit: [Character] = ["0", "1"]
    
    // get nec key code -- 32 bit
    func getNecSignalList(keycode: Int32) -> NSArray {
        var str: String = int32toBinarayString(getNecKeycode(keycode))
        var array: NSMutableArray = NSMutableArray()
        
        // add space
        //array.addObject(Signal(2000, isSignal: false))
        
        // add header
        array.addObject(Signal(head_h, isSignal: true))
        array.addObject(Signal(head_l, isSignal: false))
        
        for c in str {
            switch c {
            case "0":
                array.addObject(Signal(zero_h, isSignal: true))
                array.addObject(Signal(zero_l, isSignal: false))
            case "1":
                array.addObject(Signal(one_h, isSignal: true))
                array.addObject(Signal(one_l, isSignal: false))
            default:
                    break;
            }
        }
        
        // stop bit
        array.addObject(Signal(zero_h, isSignal: true))
        array.addObject(Signal(zero_l, isSignal: false))
        
        var result: NSArray = array.copy() as NSArray
        return result
    }
    
    func getNecKeycode(keycode: Int32) -> Int32 {
        //nec test formart: 0x07F8XXXX
        let header: Int32 = 0x07F80000
        var cmd: Int32 = (keycode << 8) | (0xFF - keycode)
        return header | cmd
    }
    
    func int32toBinarayString(value: Int32) -> String {
        var buf: [Character] = [Character](count: 32, repeatedValue: "0")
        var position: Int = 32
        var temp: Int = Int(value)
        
        do {
            buf[--position] = digit[temp & 1]
            temp >>= 1
        } while(temp != 0)
        
        
        // reverse bytes
        var result = ""
        for c in buf[24...31] {
            result = String(c) + result
        }
        for c in buf[16...23] {
            result = String(c) + result
        }
        for c in buf[8...15] {
            result = String(c) + result
        }
        for c in buf[0...7] {
            result = String(c) + result
        }
        
        return result
    }
}