// icsinterface
// $Id$

#import "ChessServerListControl.h"

@implementation ChessServerListControl

- (IBAction) userAddNewServer: (id) sender
{
	[chessServerList addNewServer];
	[serverList reloadData];
}

- (IBAction) userDeleteCurrentServer: (id) sender
{
	int i = [serverList selectedRow];
	if (i != -1)
		[chessServerList removeServerAtIndex:i];
	[serverList reloadData];
}

- (int) numberOfRowsInTableView: (NSTableView *) aTableView
{
	return [chessServerList numServers];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	NSString *name = [[chessServerList serverAtIndex:rowIndex] serverName];
	return (name != nil) ? name : @"<undefined>";
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	[[chessServerList serverAtIndex:rowIndex] setServerName: anObject];
}

- (void) tableViewSelectionDidChange:(NSNotification *)aNotification
{
	int n = [serverList selectedRow];
	if ((n < 0) || (n >= [chessServerList numServers])) {
		[serverName unbind:@"value"];
		[serverAddress unbind:@"value"];
		[serverUserName unbind:@"value"];
		[serverPassword unbind:@"value"];
		[serverPort unbind:@"value"];
		[serverInitialization bind: @"value" toObject: self withKeyPath:@"emptyString" options:nil];
		[serverName setEnabled: NO];
		[serverAddress setEnabled: NO];
		[serverUserName setEnabled: NO];
		[serverPassword setEnabled: NO];
		[serverPort setEnabled: NO];
		[serverInitialization setEditable: NO];
		[serverName setStringValue: @""];
		[serverAddress setStringValue: @""];
		[serverUserName setStringValue: @""];
		[serverPassword setStringValue: @""];
		[serverPort setIntValue: 0];
	} else {
		ChessServer *s = [chessServerList serverAtIndex: n];
		[serverName bind:@"value" toObject:s withKeyPath:@"serverName" options:nil];
		[serverAddress bind:@"value" toObject:s withKeyPath:@"serverAddress" options:nil];
		[serverUserName bind:@"value" toObject:s withKeyPath:@"userName" options:nil];
		[serverPassword bind:@"value" toObject:s withKeyPath:@"userPassword" options:nil];
		[serverPort bind:@"value" toObject:s withKeyPath:@"serverPort" options:nil];
		[serverInitialization bind:@"value" toObject:s withKeyPath:@"initCommands" options:nil];
		[serverName setEnabled: YES];
		[serverAddress setEnabled: YES];
		[serverUserName setEnabled: YES];
		[serverPassword setEnabled: YES];
		[serverPort setEnabled: YES];
		[serverInitialization setEditable: YES];
	}
}

- (ChessServer *) currentServer
{
	int n = [serverList selectedRow];
	if (n < 0)
		return nil;
	else
		return [chessServerList serverAtIndex: n];
}

- (ChessServerListControl *) initWithAppController: (AppController *) ac 
{
	if ((self = [super initWithWindowNibName: @"ServerSelector"]) != nil) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		chessServerList = [NSKeyedUnarchiver unarchiveObjectWithData: [defaults objectForKey:@"ICSChessServers"]];
		[chessServerList retain];
		appController = [ac retain];
		emptyString = [[NSMutableString stringWithString: @""] retain];
	}
	return self;
}

- (void) dealloc
{
	[chessServerList release];
	[appController release];
	[emptyString release];
	[super dealloc];
}

- (IBAction) updateDefaults: (id) sender
{
	NSData *serverData = [NSKeyedArchiver archivedDataWithRootObject:chessServerList];
	[[NSUserDefaults standardUserDefaults] setObject:serverData forKey:@"ICSChessServers"];
}

- (IBAction) buttonSelect: (id) sender
{
	[appController connectChessServer: [self currentServer]];
}

- (IBAction) buttonCancel: (id) sender
{
	[self close];
}

- (void) show: (id) sender
{
	[self showWindow: sender];
	[[self window] makeKeyAndOrderFront: sender];
}

- (void) handleStreamError: (NSError *) theError
{
	NSAlert *theAlert = [[NSAlert alloc] init]; 

	[self showWindow: nil];
	[theAlert setMessageText:@"Error reading stream!"];
	[theAlert setInformativeText:[NSString stringWithFormat:@"Error %i: %@", [theError code], [theError localizedDescription]]];
	[theAlert addButtonWithTitle:@"OK"];
    [theAlert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
	 contextInfo:nil];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
}

@end


