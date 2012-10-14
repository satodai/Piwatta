//
//  kijiManager.h
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PwManager.h"

@interface KijiManager : PwManager

@property (assign) NSInteger prevPageNumber;
@property (assign) NSInteger nextPageNumber;
@property (assign) BOOL canLoadPrevPage;
@property (assign) BOOL canLoadNextPage;

- (BOOL)loadKiji:(NSString *)dbName kijiGrp:(NSString *)kijiGrp pageNumber:(NSInteger)pageNumber;
- (BOOL)loadPreviousPage:(NSString *)dbName kijiGrp:(NSString *)kijiGrp;
- (BOOL)loadNextPage:(NSString *)dbName kijiGrp:(NSString *)kijiGrp;

@end
