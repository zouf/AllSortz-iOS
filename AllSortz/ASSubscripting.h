//
//  ASSubscripting.h
//  AllSortz
//
//  Created by Lawrence Velázquez on 8/19/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#ifndef AllSortz_ASSubscripting_h
#define AllSortz_ASSubscripting_h

/*
    Enable NSArray and NSDictionary subscripting with pre-iOS 6 SDKs
    See http://clang.llvm.org/docs/ObjectiveCLiterals.html
*/

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000

@interface NSArray (ASSubscripting)
- (id)objectAtIndexedSubscript:(NSUInteger)idx;
@end

@interface NSMutableArray (ASSubscripting)
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
@end

@interface NSDictionary (ASSubscripting)
- (id)objectForKeyedSubscript:(id)key;
@end

@interface NSMutableDictionary (ASSubscripting)
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
@end

#endif  /* subscripting */


#endif  /* AllSortz_ASSubscripting_h */
