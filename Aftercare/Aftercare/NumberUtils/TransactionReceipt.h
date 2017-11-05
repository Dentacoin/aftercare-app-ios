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

#import <Foundation/Foundation.h>

#import "Address.h"
#import "BigNumber.h"
#import "Hash.h"
#import "Transaction.h"


@interface TransactionReceipt : NSObject <NSCopying>

/**
 *   Dictionary representation
 *   - transactionHash    (hex string; 32 bytes)               *
 *   - transactionIndex   (decimal string)
 *   - blockHash          (hex string; 32 bytes)
 *   - blockNumber        (decimal string)
 *   - cumulativeGasUsed  (decimal string)
 *   - gasUsed            (decimal string)
 *   - contractAddress    (or creates; hex string; 20 bytes)
 *   - logs               (Array string; 20 bytes)               *
  */

+ (instancetype)transactionReceiptFromDictionary: (NSDictionary*)receipt;
- (NSDictionary*)dictionaryRepresentation;

+ (instancetype)transactionReceiptWithPendingTransaction: (Transaction*)transaction hash: (Hash*)transactionHash;


/**
 *  JSON Representation
 */
+ (instancetype)transactionReceiptFromJSON: (NSString*)json;
- (NSString*)jsonRepresentation;

@property (nonatomic, readonly) Hash *transHash;
//@property (nonatomic, readonly) Hash *transactionHash;
@property (nonatomic, readonly) NSInteger transactionIndex;
@property (nonatomic, readonly) NSInteger blockNumber;
@property (nonatomic, readonly) Hash *blockHash;

@property (nonatomic, readonly) Address *contractAddress;

@property (nonatomic, readonly) NSArray *logs;

@property (nonatomic, readonly) BigNumber *gasUsed;
@property (nonatomic, readonly) BigNumber *cumulativeGasUsed;

@end
