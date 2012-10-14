//
//  AppDelegate_Misc.m
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate_Misc.h"
#import "PwEditorDef.h"
#import "NSString_PwEditor.h"

@implementation AppDelegate(Misc)

- (void)synchronizeSegmentedControl
{
	NSInteger documentCount = [[self.documentArrayController content] count];
	
	NSInteger width = [self.segmentedControl widthForSegment:0];
	[self.segmentedControl setSegmentCount:documentCount];
	for (NSInteger i = 0; i < documentCount; i++) {
		[self.segmentedControl setWidth:width forSegment:i];
		[self.segmentedControl setLabel:[NSString stringWithFormat:@"%ld", i + 1] forSegment:i];
	}
	
	[self.segmentedControl sizeToFit];
	[self.segmentedControl setSelectedSegment:[self.documentArrayController selectionIndex]];
	
	[[self.appStatusController content] setValue:[NSNumber numberWithBool:(documentCount < MAX_DOCUMENT_COUNT) ? YES : NO] forKey:@"canAddPage"];
	[[self.appStatusController content] setValue:[NSNumber numberWithBool:(documentCount > 1) ? YES : NO] forKey:@"canRemovePage"];
}

- (void)synchronizeCount
{
	NSInteger count = [[self.textView string] pweByteCount];
	NSNumber *currentByte = [NSNumber numberWithInteger:count];
	NSNumber *remainByte = [NSNumber numberWithInteger:MAX_BODY_LENGTH - count];
	BOOL exceeded = ([remainByte integerValue] < 0) ? YES : NO;
	//NSLog(@"totalByte=<%ld>", [totalByte integerValue]);
	//NSLog(@"remailByte=<%ld>", [remainByte integerValue]);
	//NSLog(@"textExceeded=<%@>", textExceeded ? @"YES" : @"NO");
	[[self.appStatusController content] setValue:currentByte forKey:@"currentByte"];
	[[self.appStatusController content] setValue:remainByte forKey:@"remainByte"];
	[[self.appStatusController content] setValue:[NSNumber numberWithBool:exceeded] forKey:@"exceeded"];
	[[self.appStatusController content] setValue:[NSNumber numberWithBool:YES] forKey:@"documentEdited"];
}

- (void)saveWarningAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
	[[alert window] orderOut:self];
	
	switch (returnCode) {
		case NSAlertFirstButtonReturn:
			NSLog(@"NSAlertFirstButtonReturn");
			NSSavePanel *savePanel = [NSSavePanel savePanel];
			[savePanel setDirectory:[NSURL URLWithString:NSHomeDirectory()]];
			[savePanel setNameFieldLabel:@"名前："];
			[savePanel setNameFieldStringValue:[[self.appStatusController content] objectForKey:@"fileName"]];
			[savePanel beginSheetModalForWindow:self.window completionHandler:
			 ^(NSInteger result) {
				 if (result == NSFileHandlingPanelOKButton) {
					 [self saveToFile:[savePanel filename]];
					 [NSApp terminate:self];
				 }
			 }];
			break;
			
		case NSAlertSecondButtonReturn:
			NSLog(@"NSAlertSecondButtonReturn");
			break;
			
		case NSAlertThirdButtonReturn:
			NSLog(@"NSAlertThirdButtonReturn");
			[[self.appStatusController content] setValue:[NSNumber numberWithBool:NO] forKey:@"documentEdited"];
			[NSApp terminate:self];
			break;
	}
}

- (void)submitSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	[sheet orderOut:nil];
}

- (void)saveToFile:(NSString *)fileName
{
	[NSKeyedArchiver archiveRootObject:[self.documentArrayController content] toFile:fileName];
	[[self.appStatusController content] setValue:fileName forKey:@"fileName"];
	[[self.appStatusController content] setValue:[NSNumber numberWithBool:NO] forKey:@"documentEdited"];
}

- (void)loadTopic
{
	[NSThread detachNewThreadSelector:@selector(loadTopicThread) toTarget:self withObject:nil];
}

- (void)loadTopicThread
{
	[[self.kijiArrayController content] removeAllObjects];
	[[self.topicArrayController content] removeAllObjects];
	
	NSMutableDictionary * dbName = [[self.dbNameArrayController content] objectAtIndex:self.dbNameArrayController.selectionIndex];
	NSString *dbNameValue = [dbName objectForKey:@"value"];
	
	[[self.appStatusController content] setValue:[NSNumber numberWithBool:YES] forKey:@"loading"];
	if (![self.pworld loadTopic:dbNameValue])
		NSLog(@"errorCode = <%ld>", self.pworld.errorCode);
	
	
	
	if ([[self.topicArrayController content] count] > 0) {
		[self.topicArrayController setSelectionIndex:0];	
	}
	//else {
	//	[self setValue:[NSNumber numberWithInteger:-1] forKey:@"topicSelectionIndex"];
	//}
	

	[[self.appStatusController content] setValue:[NSNumber numberWithBool:NO] forKey:@"loading"];
	//NSLog(@"%@", @"loadTopicThread is finished.");
	//[NSThread exit];
	
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"topic", @"loaded", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PwEditorLoadFinishEvent" object:nil userInfo:userInfo];
}

- (void)loadKiji
{
	[NSThread detachNewThreadSelector:@selector(laodKijiThread) toTarget:self withObject:nil];
	//[self laodKijiThread];
}

- (void)laodKijiThread
{
	[[self.kijiArrayController content] removeAllObjects];
	
	NSMutableDictionary *dbName = [[self.dbNameArrayController content] objectAtIndex:self.dbNameArrayController.selectionIndex];
	NSString *dbNameValue = [dbName objectForKey:@"value"];
	
	NSMutableDictionary *topic = [[self.topicArrayController content] objectAtIndex:self.topicArrayController.selectionIndex];
	NSString *kijiGrp = [topic objectForKey:@"kijiGrp"];
	
	
	
	[[self.appStatusController content] setValue:[NSNumber numberWithBool:YES] forKey:@"loading"];
	
	
	[self.pworld loadKiji:dbNameValue kijiGrp:kijiGrp pageNumber:1];
	
	[[self.appStatusController content] setValue:[NSNumber numberWithBool:NO] forKey:@"loading"];
	
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"kiji", @"loaded", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PwEditorLoadFinishEvent" object:nil userInfo:userInfo];
}


@end
