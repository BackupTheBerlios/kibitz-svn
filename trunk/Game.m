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
	[ratingWhite release];
	[ratingBlack release];
	[type release];
	[super dealloc];
}

- (Game *) initWithStyle12: (NSArray *) data
{
	if ((self = [self init]) != nil) {
		[self updateWithStyle12: data];
	}
	return self;
}

- (Game *) initWithGameInfo: (NSArray *) data
{
	if ((self = [self init]) != nil) {
		[self updateWithGameInfo: data];
	}
	return self;
}

- (void) updateWithStyle12: (NSArray *) data
{
	[self setPlayerNamesWhite: [data objectAtIndex: 17] black: [data objectAtIndex: 18]];
	[self setTimeInitial: [[data objectAtIndex: 20] intValue] increment: [[data objectAtIndex: 21] intValue]];
	gameNumber = [[data objectAtIndex: 16] intValue];
	gameRelationship = [[data objectAtIndex: 19] intValue];
}

- (void) updateWithGameInfo: (NSArray *) data
{
	NSString *s;
	gameNumber = [[data objectAtIndex: 0] intValue];
	if ((s = [ChessServerConnection findTag: @"t=" in: data]) != nil) {
		[type release];
		type = [s retain];
	}
	if ((s = [ChessServerConnection findTag: @"r=" in: data]) != nil)
		rated = ([s intValue] == 1);
	if ((s = [ChessServerConnection findTag: @"pt=" in: data]) != nil)
		partnerGame = [s intValue];
	if ((s = [ChessServerConnection findTag: @"rt=" in: data]) != nil) {
		NSArray *ra = [s componentsSeparatedByString: @","];
		if ([ra count] >= 2) {
			[ratingWhite release];
			ratingWhite = [[ra objectAtIndex: 0] retain];
			[ratingBlack release];		
			ratingBlack = [[ra objectAtIndex: 1] retain];
		}
	}
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

- (void) setSideShownOnBottom: (enum Color) color
{
	sideShownOnBottom = color;
}

- (void) flipSideShownOnBottom;
{
	sideShownOnBottom = (sideShownOnBottom == BLACK) ? WHITE : BLACK;
}

- (enum Color) sideShownOnBottom
{
	return sideShownOnBottom;
}

- (enum GameRelationship) gameRelationship
{
	return gameRelationship;
}

- (void) setDefaultBoardOrientation
{
	enum Color toMove = WHITE;
	switch (gameRelationship) {
	  case -1:
		toMove = BLACK;
	  case 1:
		if ([self sideToMove] == BLACK)
			toMove = BLACK - toMove; 
	    break;
	}
    [self setSideShownOnBottom: WHITE];
}

- (enum Color) sideToMove
{
	return [lastMove sideToMove];
}

- (NSString *) ratingWhite
{
	return ratingWhite;
}

- (NSString *) ratingBlack
{
	return ratingBlack;
}

- (NSString *) type
{
	return type;
}

- (bool) rated
{
	return rated;
}

- (NSString *) whiteNameRating
{
	if (whiteName && ratingWhite)
		return [NSString stringWithFormat: @"%@\n%@", whiteName, ratingWhite];
	else
		return whiteName;
}

- (NSString *) blackNameRating
{
	if (blackName && ratingBlack)
		return [NSString stringWithFormat: @"%@\n%@", blackName, ratingBlack];
	else
		return blackName;
}

@end
