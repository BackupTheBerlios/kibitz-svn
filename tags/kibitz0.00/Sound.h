// icsinterface
// $Id$

#import "global.h"

#define NUMBER_OF_SOUNDS 8

enum SoundTypes {
	SOUND_MOVE_SELF,
	SOUND_MOVE_OPPONENT,
	SOUND_MOVE_ACTIVE,
	SOUND_MOVE_OTHER,
	SOUND_GAME_START_OWN,
	SOUND_GAME_START_OTHER,
	SOUND_GAME_END_OWN,
	SOUND_GAME_END_OTHER,
	SOUND_MESSAGE
};


@interface Sound : NSObject {
	NSSound *sounds[NUMBER_OF_SOUNDS];
	bool playFlag[NUMBER_OF_SOUNDS];
}

- (Sound *) init;
- (void) playSound: (enum SoundTypes) type;
- (void) dealloc;
- (void) gameEnd: (enum GameRelationship) r;
- (void) newGame: (enum GameRelationship) r;
- (void) move: (enum GameRelationship) r;

@end
