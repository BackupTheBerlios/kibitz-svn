// icsinterface
// $Id$

#import <Cocoa/Cocoa.h>

@class AppController;
@class ChatWindowController;
@class ChessMove;
@class ChessServer;
@class ChessServerConnection;
@class ChessServerList;
@class ChessServerListControl;
@class ChessView;
@class Game;
@class GameWindowController;
@class PatternMatching;
@class PlayView;
@class Seek;
@class Sound;
@class MoveStore;
@class OutputLine;

extern Sound *gSounds;

struct ChessField {
	int row, line;
};

enum Piece {
	PAWN = 1, KNIGHT = 2, BISHOP = 3, ROOK = 4, QUEEN = 5, KING = 6
};

enum Color {
	BLACK = 8, WHITE = 0
};

#define GETPIECE(x) ((x) & 7)
#define GETCOLOR(x) ((x) & 8)

enum CastleRights {
	WHITE_LONG = 1, WHITE_SHORT = 2, BLACK_LONG = 4, BLACK_SHORT = 8
};

enum PlayerType {
	UNREGISTERED = 1,
	COMPUTER = 2,
	GM = 4,
	IM = 8,
	FM = 0x10,
	WGM = 0x20,
	WIM = 0x40,
	WFM = 0x80
};

enum RunningClock { 
	NO_CLOCK_RUNS = 0,
	WHITE_CLOCK_RUNS = 1, 
	BLACK_CLOCK_RUNS = 2 
};

enum ValidationResult {
	INVALID, VALID, REQUIRES_PROMOTION
};

enum GameRelationship {
	OBSERVER = 0,
	PLAYING_MYMOVE = 1,
	PLAYING_OPONENT_MOVE = -1,
	EXAMINER = 2,
	OBSERVING_EXAMINATION = -2,
	ISOLATED_POSITION = -3
};

enum PlayStyle {
	STYLE_NORMAL, STYLE_CRAZYHOUSE, STYLE_SUICIDE, STYLE_WILD
};

enum WantsColor {
	WANTS_BOTH = 0, WANTS_WHITE = 1, WANTS_BLACK = 2
};

enum OutputLineType {
	OTHER, LINE_PARTIAL, LINE_USER_INPUT
};

@protocol ChessServerErrorHandler <NSObject>
- (void) handleStreamError: (NSError *) theError;
@end

#define STRBEGINS(x, y) (strncmp((x), (y), strlen(y)) == 0)

inline NSString *nil2Empty(NSString *x)
{
	if (x == nil)
		return @"";
	else
		return x;
}
