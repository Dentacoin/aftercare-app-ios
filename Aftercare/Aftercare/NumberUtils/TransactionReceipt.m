/**
 *  MIT License
 *
 *  Copyright (c) 2017 Richard Moore <me@ricmoo.com>
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the
 *  "Software"), to deal in the Software without restriction, including
 *  without limitation the rights to use, copy, modify, merge, publish,
 *  distribute, sublicense, and/or sell copies of the Software, and to
 *  permit persons to whom the Software is furnished to do so, subject to
 *  the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included
 *  in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 *  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 *  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 *  DEALINGS IN THE SOFTWARE.
 */

#import "TransactionReceipt.h"

#import "Account.h"
#import "ApiProvider.h"

@implementation TransactionReceipt

static NSData *NullData = nil;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NullData = [NSData data];
    });
}

- (instancetype)initWithDictionary: (NSDictionary*)info {
    self = [super init];
    if (self) {
        
        _transHash = queryPath(info, @"dictionary:transactionHash/hash");
        // _transactionHash = queryPath(info, @"dictionary:transactionHash/hash");
        if (!_transHash) {
            NSLog(@"TransactionReceipt ERROR: Missing transactionHash");
            return nil;
        }
        
        NSNumber *transactionIndex = queryPath(info, @"dictionary:transactionIndex/integer");
        if (transactionIndex) {
            _transactionIndex = [transactionIndex integerValue];
        } else {
            _transactionIndex = -1;
        }
        
        _blockHash = queryPath(info, @"dictionary:blockHash/hash");
        
        NSNumber *blockNumber = queryPath(info, @"dictionary:blockNumber/integer");
        if (blockNumber) {
            _blockNumber = [blockNumber integerValue];
        } else {
            _blockNumber = -1;
        }
        
        _contractAddress = [Address addressWithString:queryPath(info, @"dictionary:contractAddress/string")];
        if (!_contractAddress) {
            _contractAddress = [Address addressWithString:queryPath(info, @"dictionary:creates/string")];
        }
        
 
        
        _logs = queryPath(info, @"dictionary:logs/array");
        
        

        _gasUsed = queryPath(info, @"dictionary:gasUsed/bigNumber");

        _cumulativeGasUsed = queryPath(info, @"dictionary:cumulativeGasUsed/bigNumber");

    }
    return self;
}

- (NSDictionary*)dictionaryRepresentation {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:16];
    
    [info setObject:[_transHash hexString] forKey:@"transactionHash"];
    
    if (_transactionIndex) {
        [info setObject:[NSString stringWithFormat:@"%ld", (long)_transactionIndex] forKey:@"transactionIndex"];
    }

    if (_logs) {
        [info setObject:_logs forKey:@"logs"];
    }
    
    if (_blockHash) {
        [info setObject:[_blockHash hexString] forKey:@"blockHash"];
    }
    
    if (_blockNumber) {
        [info setObject:[NSString stringWithFormat:@"%ld", (long)_blockNumber] forKey:@"blockNumber"];
    }
    
    if (_contractAddress) {
        [info setObject:_contractAddress.checksumAddress forKey:@"contractAddress"];
    }
    
    if (_gasUsed) {
        [info setObject:[_gasUsed decimalString] forKey:@"gasUsed"];
    }
    
    if (_cumulativeGasUsed) {
        [info setObject:[_cumulativeGasUsed decimalString] forKey:@"cumulativeGasUsed"];
    }
    
    
    return info;
}

+ (instancetype)transactionReceiptFromDictionary: (NSDictionary*)receipt {
    return [[TransactionReceipt alloc] initWithDictionary:receipt];
}

+ (instancetype)transactionReceiptFromJSON:(NSString *)json {
    NSError *error = nil;
    NSDictionary *receipt = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error) {
        NSLog(@"ERROR: %@", error);
        return nil;
    }
    
    return [[TransactionReceipt alloc] initWithDictionary:receipt];
}

+ (instancetype)transactionReceiptWithPendingTransaction: (Transaction*)transaction hash: (Hash*)transactionHash {
    
    NSDictionary *transactionReceipt = @{
                                         @"transactionHash": [transactionHash hexString]
                                      };
    
    return [TransactionReceipt transactionReceiptFromDictionary:transactionReceipt];
}

- (NSString*)jsonRepresentation {
    NSDictionary *receipt = [self dictionaryRepresentation];
    
    NSError *error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:receipt options:0 error:&error];
    if (error) {
        NSLog(@"ERROR: %@", error);
        return nil;
    }
    
    return [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return self;
}


#pragma mark - NSObject

- (NSUInteger)hash {
    return [_transHash hash];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[TransactionReceipt class]]) { return NO; }
    return [_transHash isEqualToHash:((TransactionReceipt*)object).transHash];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"<TransactionReceipt transactionHash=%@ transactionIndex=%ld blockNumber=%ld blockHash=%@ cumulativeGasUsed=%@ gasUsed=%@  contractAddress=%@ logs=%@>",
            [_transHash hexString], (unsigned long)_transactionIndex,(unsigned long)_blockNumber, [_blockHash hexString], [_cumulativeGasUsed decimalString], [_gasUsed decimalString], _contractAddress, _logs.description
            ];
}

@end
