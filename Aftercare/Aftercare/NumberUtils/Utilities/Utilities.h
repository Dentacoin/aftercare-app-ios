//
//  Utilities.h
//  ethers
//
//  Created by Richard Moore on 2017-02-01.
//  Copyright © 2017 Ethers. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSData* convertIntegerToData(NSUInteger value);
// queryPath(object, @"dictionary:someKey/array:0/integerHex")
// Supported types: dictionary:, array:, string, integerHex, integerDecimal, float
//                  bigNumberHex, bigNumberDecimal, data, hash, object
id queryPath(NSObject *object, NSString *path);
