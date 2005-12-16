// icsinterface
// $Id$

#import "ChessServerConnection.h"
#import "Game.h"
#import "GameWindowController.h"
#import "PatternMatching.h"

#define USERNAME_REGEX "[A-z]{3,17}"
#define TITLES_REGEX "\\([A-Z\\*\\(\\)]*\\)"

@implementation ChessServerConnection

- (void) serverGameEnd: (NSNumber *) game result: (NSString *) result reason: (NSString *) reason
{
	NSLog(@"Game end\n");
	Game *g = [activeGames objectForKey: game]; 
	if (g != nil) {
		[g setResult: result reason: reason];
		[activeGames removeObjectForKey: game];
		[activeGames setObject: g forKey: [NSNumber numberWithInt: --storedGameCounter]]; 
		[serverMainWindow setGameList: activeGames];
	}
}

- (void) processServerOutput
{
	NSInvocation *invoc;
	
	if (serverMainWindow == nil) {
		serverMainWindow = [[GameWindowController alloc] initWithServerConnection: self];
		[serverMainWindow showWindow: self];
	}
	if (strncmp(lineBuf,"<12>", 4) == 0) {
		NSArray *a = [[[NSString stringWithCString: lineBuf] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString: @" "];
		NSNumber *n = [NSNumber numberWithInt: [[a objectAtIndex: 16] intValue]];
		Game *g = [activeGames objectForKey: n];
		if (g == nil) {
			g = [[Game alloc] initWithStyle12: a];
			[activeGames setObject: g forKey: n];
			[serverMainWindow setGameList: activeGames];
			[serverMainWindow setActiveGame: g];
		}
		[g newMove: [ChessMove moveFromStyle12: a]];
		[serverMainWindow updateGame: g];
	} else if (strncmp(lineBuf,"<s>", 3) == 0) {
		int num = 0;
		sscanf(lineBuf + 3, " %d", &num);
		[self newSeekFromServer: num description: lineBuf + 4];
	} else if (strncmp(lineBuf,"<sr>", 4) == 0) {
		NSArray *sr = [[[NSString stringWithCString:lineBuf + 4] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString: @" "];
		NSEnumerator *enumerator = [sr objectEnumerator];
		NSString *s;
		
		while (s = [enumerator nextObject]) {
			int num = [s intValue];
			[self removeSeekFromServer: num];
		}
	} else if (strncmp(lineBuf,"<sc>", 4) == 0) {
		[self removeAllSeeks];
	} else if (strncmp(lineBuf,"login:", 6) == 0) {
		if (currentServer != nil && sendNamePassword == YES) {
			const char *s;
			sendNamePassword = NO;
			if ([currentServer userName] && [currentServer userPassword]) {
				s = [[currentServer userName] UTF8String];
				[serverOS write:(unsigned const char *) s maxLength:strlen(s)];
				[serverOS write:(unsigned const char *) "\n" maxLength:1];
				s = [[currentServer userPassword] UTF8String];
				[serverOS write:(unsigned const char *) s maxLength:strlen(s)];
				[serverOS write:(unsigned const char *) "\n" maxLength:1];
			}
		}
	} else if (strncmp(lineBuf,"fics%", 5) == 0) {
		if (sendInit) {
			const char *s;
			sendInit = NO;
			if (s = [[currentServer initCommands] UTF8String]) {
				[serverOS write:(unsigned const char *) s maxLength:strlen(s)];
				[serverOS write:(unsigned const char *) "\n" maxLength:1];
			}
		}
//	} else if (handleGameInfo(line)) {
//	} else if (handleDeltaBoard(line)) {
//	} else if (handleBughouseHoldings(line)) {
	} else if (invoc = [patternMatcher parseLine: lineBuf toTarget: self]) {
		[invoc invoke];
	/* (STRBEGINS(lineBuf, "{Game ")) {
		
		NSLog(@"Game end\n");
		NSArray *a = matchPattern(serverOutput, PATTERN_GAME_END);
		NSNumber *gameNum = [NSNumber numberWithInt:[[a objectAtIndex: 1] intValue]];
		Game *g = [activeGames objectForKey: gameNum]; 
		NSLog(@"%@\n", a);
		if (g != nil) {
			[g setResult: [a objectAtIndex: 5] reason: [a objectAtIndex: 4]];
			[activeGames removeObjectForKey: gameNum];
			[activeGames setObject: g forKey: [NSNumber numberWithInt: --storedGameCounter]]; 
			[serverMainWindow setGameList: activeGames];
		}
//	} else if (handleStoppedObserving(line)) {
//	} else if (handleStoppedExamining(line)) {
//	} else if (handleEnteredBSetupMode(line)) {
//	} else if (handleExitedBSetupMode(line)) {
//	} else if (handleIllegalMove(line)) {
//	} else if (handleChannelTell(line)) {
//    } else if (handleIvarStateChanged(line)) {
//	} else if (handlePersonalTell(line)) {
//	} else if (handleSayTell(line)) {
//	} else if (handlePTell(line)) {
//	} else if (handleShout(line)) {
//	} else if (handleIShout(line)) {
//	} else if (handleTShout(line)) {
//	} else if (handleCShout(line)) {
//	} else if (handleAnnouncement(line)) {
//	} else if (handleKibitz(line)) {
//	} else if (handleWhisper(line)) {
//	} else if (handleQTell(line)) {
//	} else if (handleOffer(line)) {
//    } else if (handleOfferRemoved(line)) {
//    } else if (handlePlayerOffered(line)) {                  
//    } else if (handlePlayerDeclined(line)) { 
//    } else if (handlePlayerWithdrew(line)) {
//    } else if (handlePlayerCounteredTakebackOffer(line)) {             
//    } else if (handleSimulCurrentBoardChanged(line)) {
//    } else if (handlePrimaryGameChanged(line)) {
*/
	} else {
		[serverMainWindow addToServerOutput:[NSString stringWithUTF8String:(char *) lineBuf]];
		[serverMainWindow addToServerOutput:@"\n"];
	}
}

- (void) stream: (NSStream *) theStream handleEvent:(NSStreamEvent)event
{
	char c;
	int i;
	
	switch(event) {
	  case NSStreamEventHasBytesAvailable: {
		unsigned char buf[2048];
		unsigned int len = 0;
		while (len = [(NSInputStream *) theStream read:buf maxLength: 2048]) {
			for (i = 0; i < len; i++) {
				switch (c = buf[i]) {
				  case 10: 
					lineBuf[lastChar] = 0;
					lastChar = 0;
					[self processServerOutput];
					break;
				  case 13:
					break;
				  default:
					lineBuf[lastChar++] = c;
					break;
				}
			}
			if (len < 2048) { // !!! dirty code
				if (lastChar > 0) {
					lineBuf[lastChar] = 0;
					lastChar = 0;
					[self processServerOutput];
				}
				break;
			}
		}
		break;
	  }
	  case NSStreamEventErrorOccurred:
		[errorHandler handleStreamError: [theStream streamError]];
		[self release];
		break;
	}
}

- (id) initWithChessServer: (ChessServer *) server {
	struct ServerPattern serverPatterns[] = {
		{ "^\\{Game ([0-9]+) \\((" USERNAME_REGEX ") vs\\. (" USERNAME_REGEX ")\\) ([^\\}]+)\\} (.*)", @selector(serverGameEnd:result:reason:), "1I54" },
		{ 0, 0, 0 }
	};

	self = [self init];
	if (self != nil) {
		[self retain];
		currentServer = [server retain];
		NSHost *host = [NSHost hostWithName: [server serverAddress]];
		[NSStream getStreamsToHost:host port:5000 inputStream: &serverIS outputStream: &serverOS];
		[serverIS retain];
		[serverOS retain];
		[serverIS setDelegate: self];
		[serverOS setDelegate: self];
		[serverIS scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[serverOS scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[serverIS open];
		[serverOS open];
		sendNamePassword = YES;
		sendInit = YES;
		[self release];
		patternMatcher = [[PatternMatching alloc] initWithPatterns: serverPatterns];
	}
	return self;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		activeGames = [[NSMutableDictionary alloc] init];
		seeks = [[NSMutableDictionary dictionaryWithCapacity:500] retain];
		lastChar = 0;
	}
	return self;
}

- (void) dealloc
{
	[activeGames release];
	[serverIS close];
	[serverOS close];
	[serverIS release];
	[serverOS release];
	[seeks release];
	[currentServer release];
	[serverMainWindow release];
	[errorHandler release];
	[patternMatcher release];
	[super dealloc];
}

- (void) setErrorHandler: (id) eh
{
	[errorHandler release];
	errorHandler = eh;
	[eh retain];
}

- (void) write: (unsigned char *) data maxLength: (int) i
{
	[serverOS write: data maxLength:i ];
}

- (void) newSeekFromServer: (int) num description: (const char *) seekInfo
{
	Seek *s = [Seek seekFromSeekInfo: seekInfo];
	if (s != nil) {
		[seeks setObject: s forKey: [NSNumber numberWithInt: num]];
		[serverMainWindow seekTableNeedsDisplay];
	} else
		NSLog(@"Error in Seek request");
}

- (void) removeSeekFromServer: (int) num
{
	[seeks removeObjectForKey: [NSNumber numberWithInt: num]];
	[serverMainWindow seekTableNeedsDisplay];
}

- (void) removeAllSeeks
{
	[seeks removeAllObjects];
	[serverMainWindow seekTableNeedsDisplay];	
}

- (int) numSeeks
{
	return [seeks count];
}

- (id) dataForSeekTable: (NSString *) x row:(int)rowIndex;
{
	NSNumber *key = [[seeks allKeys] objectAtIndex: rowIndex];
	if ([x compare: @"#"] == 0) {
		return key;
	} else {
		Seek *s = [seeks objectForKey:key];
		if ([x compare: @"Name"] == 0) {
			return [s nameFrom];
		} else if ([x compare: @"Rating"] == 0) {
			return [NSNumber numberWithInt: [s ratingValue]];
		} else if ([x compare: @"Type"] == 0) {
			return [s typeOfPlay];
		} else
			return nil;
	}
}

- (void) userMoveFrom: (struct ChessField) from to: (struct ChessField) to
{
	[self userMoveFrom: from to: to promotion: 0];
}

- (void) userMoveFrom: (struct ChessField) from to: (struct ChessField) to promotion: (int) promotionPiece
{
	unsigned char move[10];
	
	move[0] = from.line + 'a' - 1;
	move[1] = from.row + '1' - 1;
	move[2] = '-';
	move[3] = to.line  + 'a' - 1;
	move[4] = to.row + '1' - 1;
	if ((promotionPiece < 2) || (promotionPiece > 5)) {
		move[5] = '\n';
		move[6] = 0;
	} else {
		move[5] = '=';
		move[6] = "  NBRQ"[promotionPiece];
		move[7] = '\n';
		move[8] = 0;
	}
	[serverOS write: move maxLength: strlen((char *) move)];
} 

@end
