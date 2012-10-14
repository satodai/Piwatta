//
//  AppDelegate_Misc.h
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface AppDelegate(Misc)

- (void)synchronizeSegmentedControl;
- (void)synchronizeCount;
- (void)saveToFile:(NSString *)fileName;
- (void)saveToFile:(NSString *)fileName;
- (void)loadTopic;
- (void)loadKiji;

- (void)loadTopicThread;
- (void)laodKijiThread;

@end
