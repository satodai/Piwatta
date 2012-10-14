//
//  NSString_PwEditor.h
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(PwEditor)

- (NSString *)substringFromPattern:(NSString *)pattern;
- (NSString *)substringFromPattern:(NSString *)openPattern toPattern:(NSString *)closePattern;
- (NSInteger)integerValueFromPattern:(NSString *)openPattern toPattern:(NSString *)closePattern;
- (NSDate *)dateValue;
- (NSString *)stringByReplacingOccurrencesOfEscapeChar;
- (NSInteger)pweByteCount;

@end
