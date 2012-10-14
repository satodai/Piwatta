//
//  PwManager.h
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PWorld;
@interface PwManager : NSObject

@property (assign) PWorld *pworld;

- (id)initWithPWorld:(PWorld *)pworld;

@end
