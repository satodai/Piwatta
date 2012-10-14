//
//  AppDelegate.m
//  PwEditor
//
//  Created by Daisuke Sato on 12/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate_Misc.h"
#import "DateFormatTransformer.h"
#import "PwEditorDef.h"
#import "PWorld.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize textView = _textView;
@synthesize segmentedControl = _segmentedControl;
@synthesize submitWindow = _submitWindow;
@synthesize documentArrayController = _documentArrayController;
@synthesize appStatusController = _appStatusController;
@synthesize dbNameArrayController = _dbNameArrayController;
@synthesize topicArrayController = _topicArrayController;
@synthesize kijiArrayController = _kijiArrayController;

@synthesize submitPanelTabView = _submitPanelTabView;

@synthesize pworld = _pworld;

- (void)dealloc
{
    [super dealloc];
}
	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(OnLoadThreadEnd:) name:@"PwEditorLoadFinishEvent" object:nil];
	
	DateFormatTransformer *transformaer = [[DateFormatTransformer alloc] init];
    [NSValueTransformer setValueTransformer:transformaer forName:@"DateFormatTransFormer"];
	
	NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
	NSInteger pagesToLoad = [userDefaults integerForKey:PAGES_TO_LOAD];
	if (pagesToLoad == 0)
		[userDefaults setInteger:3 forKey:PAGES_TO_LOAD];
	
	_pworld = [[PWorld alloc] initWithDbNameArray:_dbNameArrayController topicArray:_topicArrayController kijiArray:_kijiArrayController];

	[[_appStatusController content] setValue:[NSNumber numberWithBool:NO] forKey:@"loading"];
	[[_appStatusController content] setValue:[NSNumber numberWithBool:YES] forKey:@"canAddPage"];
	[[_appStatusController content] setValue:[NSNumber numberWithBool:NO] forKey:@"canRemovePage"];
	[[_appStatusController content] setValue:@"このトピックにまだ投稿はありません" forKey:@"kijiCount"];
	[[_appStatusController content] setValue:[NSNumber numberWithInteger:0] forKey:@"currentByte"];
	[[_appStatusController content] setValue:[NSNumber numberWithInteger:MAX_BODY_LENGTH] forKey:@"remainByte"];
	[[_appStatusController content] setValue:[NSNumber numberWithBool:NO] forKey:@"exceeded"];
	[[_appStatusController content] setValue:[NSNumber numberWithBool:NO] forKey:@"documentEdited"];
	[[_appStatusController content] setValue:@"名称未設定" forKey:@"fileName"];
	
	
	if (![_pworld loadDbName])
		NSLog(@"loadDbName error = <%ld>", _pworld.errorCode);
	
	if ([[_dbNameArrayController content] count] > 0)
		_dbNameArrayController.selectionIndex = 0;
	
	[self loadTopic];
	
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	if ([_window isDocumentEdited]) {
		[_documentArrayController commitEditing];
		
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"保存..."];
		[alert addButtonWithTitle:@"キャンセル"];
		[alert addButtonWithTitle:@"保存しない"];
		[alert setMessageText:[NSString stringWithFormat:@"書類「%@」に加えた変更を保存しますか？", [[_appStatusController content] objectForKey:@"fileName"]]];
		[alert setInformativeText:@"保存しないと、変更内容は失われます。"];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:_window modalDelegate:self didEndSelector:@selector(saveWarningAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
		
		return NSTerminateCancel;
	}
	
	return NSTerminateNow;
}

- (void) OnLoadThreadEnd:(NSNotification *)notification
{
	NSString *item = [[notification userInfo] objectForKey:@"loaded"];
	NSLog(@"%@", item);
	
	if ([item isEqualToString:@"topic"]) {
		[self loadKiji];
	}
	else if ([item isEqualToString:@"kiji"]) {
		NSString *s = [NSString stringWithFormat:@"%ld 件の投稿があります", 10];
		[[_appStatusController content] setValue:s forKey:@"kijiCount"];
	}
}

- (IBAction)onFileNew:(id)sender
{
	[[_documentArrayController content] removeAllObjects];
	
	NSMutableDictionary *document = [NSMutableDictionary dictionary];
	[document setObject:@"new document" forKey:@"body"];
	[_documentArrayController addObject:document];
	
	[[_appStatusController content] setValue:[NSNumber numberWithBool:NO] forKey:@"documentEdited"];
	[self synchronizeSegmentedControl];
	[self synchronizeCount];
}

- (IBAction)onFileOpen:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel beginSheetModalForWindow:self.window completionHandler:
	 ^(NSInteger result) {
		 if (result == NSFileHandlingPanelOKButton) {
			 NSString *fileName = [openPanel filename];
			 [[_appStatusController content] setValue:fileName forKey:@"fileName"];
			 [_documentArrayController setContent:[NSKeyedUnarchiver unarchiveObjectWithFile:fileName]];
			 [[_appStatusController content] setValue:[NSNumber numberWithBool:NO] forKey:@"documentEdited"];
			 [self synchronizeSegmentedControl];
			 [self synchronizeCount];
		 }
	 }
	 ];
}

- (IBAction)onFileSave:(id)sender
{
	NSString *fileName = [[_appStatusController content] objectForKey:@"fileName"];
	if ([fileName length] == 0)
		[self onFileSaveAs:sender];
	else
		[self saveToFile:fileName];
}

- (IBAction)onFileSaveAs:(id)sender
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setDirectory:[NSURL URLWithString:NSHomeDirectory()]];
	[savePanel setNameFieldLabel:@"名前："];
	[savePanel setNameFieldStringValue:[[_appStatusController content] valueForKey:@"fileName"]];
	[savePanel beginSheetModalForWindow:self.window completionHandler:
	 ^(NSInteger result) {
		if (result == NSFileHandlingPanelOKButton) {
			[self saveToFile:[savePanel filename]];
		}
	 }
	 ];
}

- (IBAction)onPageSelected:(id)sender
{
	[self synchronizeCount];
}

- (IBAction)onAddPage:(id)sender
{
	if ([[_documentArrayController content] count] >= MAX_DOCUMENT_COUNT)
		return;
	
	[_documentArrayController commitEditing];
	
	//NSString *title = [NSString string];
	NSString *body = @"テキストを入力してください";
	NSMutableDictionary *document = [NSMutableDictionary dictionaryWithObjectsAndKeys:body, @"body", nil];
	
	[_documentArrayController addObject:document];
	[[_appStatusController content] setValue:[NSNumber numberWithBool:YES] forKey:@"documentEdited"];
	[self synchronizeSegmentedControl];
	[self synchronizeCount];
}

- (IBAction)onRemovePage:(id)sender
{
	if ([[_documentArrayController content] count] == 1)
		return;
	
	//NSInteger selectionIndex = [_documentArrayController selectionIndex];
	NSMutableDictionary *currentDocument = [[_documentArrayController content] objectAtIndex:[_documentArrayController selectionIndex]];
	//NSString *textIncurrentPage = [_textView string];
	NSString *currentText = [currentDocument valueForKey:@"body"];
	
	
	//NSArray *arrangedObjects = [_documents arrangedObjects];
	NSMutableDictionary *prevDocument = [[_documentArrayController content] objectAtIndex:[_documentArrayController selectionIndex] - 1];
	NSString *prevText = [prevDocument valueForKey:@"body"];
	NSString *text = [prevText stringByAppendingString:currentText];
	[prevDocument setValue:text forKey:@"body"];
	
	[_documentArrayController remove:nil];
	
	[[_appStatusController content] setValue:[NSNumber numberWithBool:YES] forKey:@"documentEdited"];
	[self synchronizeSegmentedControl];
	[self synchronizeCount];
}

- (IBAction)dbNameSelected:(id)sender
{
	[self loadTopic];
}

- (IBAction)onTopicSelected:(id)sender
{
	[self loadKiji];
}

- (IBAction)onOpenTopic:(id)sender
{
	NSMutableDictionary *dbName = [[_dbNameArrayController content] objectAtIndex:[_documentArrayController selectionIndex]];
	NSString *dbNameValue = [dbName objectForKey:@"value"];
	
	NSMutableDictionary *topic = [[_topicArrayController content] objectAtIndex:[_topicArrayController selectionIndex]];
	NSString *kijiGrp = [topic objectForKey:@"kijiGrp"];
	
	NSString *urlStr = [NSString stringWithFormat:@"http://www.p-world.co.jp/community/keiziban2disp.cgi?mode=kiji&kiji_grp=%@&dbname=%@", kijiGrp, dbNameValue];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlStr]];
}

- (IBAction)onPrevPage:(id)sender {
}

- (IBAction)onNextPage:(id)sender {
}

- (IBAction)onReload:(id)sender {
}

- (IBAction)onSubmit:(id)sender
{
	[NSApp beginSheet:_submitWindow modalForWindow:_window modalDelegate:self didEndSelector:@selector(submitSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}


@end
