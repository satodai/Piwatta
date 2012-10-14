//
//  DateFormatTransformer.h
//  PwEditorMac
//
//  Created by Daisuke Sato on 12/10/05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateFormatTransformer : NSValueTransformer

+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;
- (id)transformedValue:(id)value;

@end
