// icsinterface
// $Id$

#import "Sound.h"

NSString *soundNames[NUMBER_OF_SOUNDS] = {
	[SOUND_MOVE_SELF] = @"SoundMoveSelf",
	[SOUND_MOVE_OPPONENT] = @"SoundMoveOther",
	[SOUND_MOVE_ACTIVE] = @"SoundMoveOther",
	[SOUND_MOVE_OTHER] = @"SoundMoveOther",
	[SOUND_GAME_START_OWN] = @"SoundNewGame",
	[SOUND_GAME_START_OTHER] = @"SoundNewGame",
	[SOUND_GAME_END_OWN] = @"SoundGameEnd",
	[SOUND_GAME_END_OTHER] = @"SoundGameEnd"
};

bool soundPlayDefaults[NUMBER_OF_SOUNDS] = { YES, YES, YES, NO, YES, NO, YES, NO };

@implementation Sound

- (Sound *) init
{
	if ((self = [super init]) != nil) {
		int i;
		for (i = 0; i < NUMBER_OF_SOUNDS; i++) {
			sounds[i] = [[NSSound soundNamed: soundNames[i]] retain];
			playFlag[i] = soundPlayDefaults[i];
		}
	}
	return self;
}

- (void) playSound: (enum SoundTypes) type
{
	if ((sounds[type] != nil) && playFlag[type])
		[sounds[type] play];
}

- (void) dealloc
{
	int i;
	for (i = 0; i < NUMBER_OF_SOUNDS; i++)
		[sounds[i] release];	
	[super dealloc];
}

- (void) gameEnd: (enum GameRelationship) r
{
	switch (r) {
	  case OBSERVER:
	  case EXAMINER:
	  case OBSERVING_EXAMINATION:
	  case ISOLATED_POSITION:	
		[self playSound: SOUND_GAME_END_OTHER];
		break;
	  case PLAYING_MYMOVE:
	  case PLAYING_OPONENT_MOVE:
		[self playSound: SOUND_GAME_END_OWN];
		break;
	}
}

- (void) newGame: (enum GameRelationship) r
{
	switch (r) {
	  case OBSERVER:
	  case EXAMINER:
	  case OBSERVING_EXAMINATION:
	  case ISOLATED_POSITION:	
		[self playSound: SOUND_GAME_START_OTHER];
		break;
	  case PLAYING_MYMOVE:
	  case PLAYING_OPONENT_MOVE:
		[self playSound: SOUND_GAME_START_OWN];
		break;
	}
}

- (void) move: (enum GameRelationship) r
{
	switch (r) {
	  case OBSERVER:
	  case EXAMINER:
	  case OBSERVING_EXAMINATION:
	  case ISOLATED_POSITION:	
		[self playSound: SOUND_MOVE_ACTIVE];
		break;
	  case PLAYING_MYMOVE:
		[self playSound: SOUND_MOVE_SELF];
		break;
	  case PLAYING_OPONENT_MOVE:
		[self playSound: SOUND_MOVE_OPPONENT];
		break;
	}
}

@end
