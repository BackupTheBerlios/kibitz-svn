// icsinterface
// $Id$

#import <ctype.h>
#import "Game.h"
#import "Board.h"

@implementation Game

- (void) setPlayerNamesWhite: (NSString *) white black: (NSString *) black
{
	[whiteName release];
	whiteName = [white retain];
	[blackName release];
	blackName = [black retain];
}

- (NSString *) whiteName
{
	return [[whiteName retain] autorelease];
}

- (NSString *) blackName
{
	return [[blackName retain] autorelease];
}

- (void) setTimeInitial: (int) initial increment: (int) increment
{
	initialTime = initial;
	incrementTime = increment;
}

- (int) initialTime
{
	return initialTime;
}

- (int) incrementTime
{
	return incrementTime;
}

- (Board *) currentBoardPosition
{
	return [lastMove positionAfter];
}

- (void) newMove: (ChessMove *) move
{
	[lastMove release];
	lastMove = [move retain];
}

- (void) dealloc
{
	[whiteName release];
	[blackName release];
	[lastMove release];
	[super dealloc];
}

- (Game *) initWithStyle12: (NSArray *) data
{
	if ((self = [self init]) != nil) {
		[self setPlayerNamesWhite: [data objectAtIndex: 17] black: [data objectAtIndex: 18]];
		[self setTimeInitial: [[data objectAtIndex: 20] intValue] increment: [[data objectAtIndex: 21] intValue]];
		gameNumber = [[data objectAtIndex: 16] intValue];
		gameRelationship = [[data objectAtIndex: 19] intValue];
	}
	return self;
}

- (Game *) initWithEmptyGame
{
	if ((self = [self init]) != nil) {
		[self setPlayerNamesWhite: @"White" black: @"Black"];
		lastMove = [[ChessMove initialPosition] retain];
		initialTime = -1;
	}
	return self;
}

- (NSString *) gameInfoString
{
	if (result)
		return [NSString stringWithFormat: @"was Game #%d: %@ - %@, (%d+%d), Result: %@", gameNumber, whiteName, blackName, initialTime, incrementTime, result];
	else
		return [NSString stringWithFormat: @"Game #%d: %@ - %@ (%d+%d)", gameNumber, whiteName, blackName, initialTime, incrementTime];
}

- (void) setResult: (NSString *) resultV reason: (NSString *) reasonV
{
	[result release];
	result = [resultV retain];
	[reason release];
	reason = [reasonV retain];
	[[lastMove positionAfter] stopClock];
}

- (NSString *) result
{
	return result;
}

- (NSString *) reason
{
	return reason;
}

- (void) setSiteShownOnBottom: (enum Color) color
{
	siteShownOnBottom = color;
}

- (void) flipSiteShownOnBottom;
{
	siteShownOnBottom = (siteShownOnBottom == BLACK) ? WHITE : BLACK;
}

- (enum Color) siteShownOnBottom
{
	return siteShownOnBottom;
}

- (enum GameRelationship) gameRelationship
{
	return gameRelationship;
}

@end
