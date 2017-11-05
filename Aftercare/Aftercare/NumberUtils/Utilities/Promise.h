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

/**
 *  Promise
 *
 *  A Promise provides a mechanism to execute and manage asynchronous tasks.
 *
 *  The setup function is called immediately, on the current thread. The setup function
 *  is expected to call exactly one of:
 *    - @selector(resolve:)
 *    - @selector(reject:)
 *
 *  Exactly one of `result` or `error` will be non-nil after the Promise is complete. If
 *  the Promise was resolved with nil, the result will have the value [NSNull null]. If the
 *  Promise is rejected with nil, an Error will be created with the domain PromiseErrorDomain.
 *
 *  The onCallback handlers are:
 *     - called on the main thread
 *     - called in the order in which they were added
 *     - never called in the same event loop (deferred, even if complete)
 *
 *  All operations are thread-safe.
 */

#import <Foundation/Foundation.h>

#import "BigNumber.h"
#import "BlockInfo.h"
#import "Hash.h"
#import "TransactionInfo.h"
#import "TransactionReceipt.h"


#pragma mark -
#pragma mark - Promise


extern NSErrorDomain PromiseErrorDomain;

@class ArrayPromise;


@interface IPromise : NSObject


#pragma mark - Creating a new Promise

- (instancetype)initWithSetup: (void (^)(IPromise*))setupCallback;

+ (instancetype)promiseWithSetup: (void (^)(IPromise*))setupCallback;

+ (instancetype)resolved: (NSObject*)result;
+ (instancetype)rejected: (NSError*)error;

+ (ArrayPromise*)all: (NSArray<IPromise*>*)promises;

// Like JavaScript's race, whichever returns first
//+ (inst)any: (NSArray<Promise*>*)promises;

// @TODO: We can replace fallback with this... Try each one until one success (or all fail)
//+ (inst)serialFallback: (NSArray<Promise*>*)promises;


#pragma mark - Querying the current state and resolution status

@property (atomic, readonly) BOOL complete;

@property (atomic, readonly) NSObject *result;
@property (atomic, readonly) NSError *error;


#pragma mark - Resolving or rejecting a Promise (only one of these may be called, and only once)

- (void)resolve: (NSObject*)result;
- (void)reject: (NSError*)error;


#pragma mark - Adding a callback to be notified on completion (this may be called many times, including after complete)

- (void)onCompletion: (void (^)(IPromise*))completionCallback;

@end


#pragma mark -
#pragma mark - ArrayPromise

@interface ArrayPromise: IPromise

@property (atomic, readonly) NSArray *value;

- (void)onCompletion: (void (^)(ArrayPromise*))completionCallback;

@end


#pragma mark -
#pragma mark - BigNumberPromise

@interface BigNumberPromise: IPromise

@property (atomic, readonly) BigNumber *value;

- (void)onCompletion: (void (^)(BigNumberPromise*))completionCallback;

@end


#pragma mark -
#pragma mark - BlockInfoPromise

@interface BlockInfoPromise: IPromise

@property (atomic, readonly) BlockInfo *value;

- (void)onCompletion: (void (^)(BlockInfoPromise*))completionCallback;

@end


#pragma mark -
#pragma mark - DataPromise

@interface DataPromise: IPromise

@property (atomic, readonly) NSData *value;

- (void)onCompletion: (void (^)(DataPromise*))completionCallback;

@end


//#pragma mark -
//#pragma mark - DictionaryPromise
//
//@interface DictionaryPromise: Promise
//
//@property (atomic, readonly) NSDictionary *value;
//
//- (void)onCompletion: (void (^)(DictionaryPromise*))completionCallback;
//
//@end


#pragma mark -
#pragma mark - FloatPromise

@interface FloatPromise: IPromise

@property (atomic, readonly) float value;

- (void)onCompletion: (void (^)(FloatPromise*))completionCallback;

@end


#pragma mark -
#pragma mark - HashPromise

@interface HashPromise: IPromise

@property (atomic, readonly) Hash *value;

- (void)onCompletion: (void (^)(HashPromise*))completionCallback;

@end


#pragma mark -
#pragma mark - IntegerPromise

@interface IntegerPromise: IPromise

@property (atomic, readonly) NSInteger value;

- (void)onCompletion: (void (^)(IntegerPromise*))completionCallback;

@end


#pragma mark -
#pragma mark - NumberPromise

@interface NumberPromise: IPromise

@property (atomic, readonly) NSNumber *value;

- (void)onCompletion: (void (^)(NumberPromise*))completionCallback;

@end


#pragma mark -
#pragma mark - StringPromise

@interface StringPromise: IPromise

@property (atomic, readonly) NSString *value;

- (void)onCompletion: (void (^)(StringPromise*))completionCallback;

@end


#pragma mark -
#pragma mark - TransactionInfoPromise

@interface TransactionInfoPromise: IPromise

@property (atomic, readonly) TransactionInfo *value;

- (void)onCompletion: (void (^)(TransactionInfoPromise*))completionCallback;

@end

#pragma mark -
#pragma mark - TransactionReceiptPromise

@interface TransactionReceiptPromise: IPromise

@property (atomic, readonly) TransactionReceipt *value;

- (void)onCompletion: (void (^)(TransactionReceiptPromise*))completionCallback;

@end


