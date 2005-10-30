//
//  Seek.m
//  icsinterface
//
//  Created by Thul Klaus on 10/23/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "Seek.h"


@implementation Seek

+ (Seek *) seekFromSeekInfo: (const char *) seekInfo
{
	const char *cp, *key, *value;
	int key_length, value_length;
	Seek *s = [[Seek alloc] init];
	[s autorelease];
	
	for (cp = seekInfo; *cp;) {
		if (!isalpha(*cp)) {
			cp++;
			continue;
		}
		key = cp;
		while (*(++cp) != '=') {
			if (!(*cp))
				goto error;
		}
		key_length = cp - key;
		value = ++cp;
		if (!(*cp)) {
			NSLog(@"Input ends after =\n");
			goto error;
		}
		while (*cp && !isspace(*cp))
			cp++;
		value_length = cp - value;
		
		if (key_length == 1) {
			switch (*key) {
			  case 'w':
				s->nameFrom = [NSString stringWithCString:value length:value_length];
				[s->nameFrom retain];
				break;
			  case 't':
				s->timeStart = atoi(value);
				break;
			  case 'i':
				s->timeIncrement = atoi(value);
				break;				
			  case 'r':
				switch (*value) {
				  case 'r':
				    s->rated = YES;
					break;
				  case 'u':
				    s->rated = NO;
					break;
				}
				break;
			  case 'c':
				s->wantsColor = *value;
				break;
			  case 'a':
				switch (*value) {
				  case 't':
				    s->automatic = YES;
					break;
				  case 'f':
				    s->automatic = NO;
					break;
				}
				break;
			  case 'f':
				switch (*value) {
				  case 't':
				    s->formulaChecked = YES;
					break;
				  case 'f':
				    s->formulaChecked = NO;
					break;
				}
				break;
			  default:
				goto unknown_key;
			}
		} else if (key_length == 2) {
			if (strncmp(key, "ti", 2) == 0) {
				s->title = (*value - '0')*16 + (*(value + 1) - '0');
			} else if (strncmp(key, "rt", 2) == 0) {
				s->ratingValue = atoi(value);
			} else if (strncmp(key, "tp", 2) == 0) {
				s->typeOfPlay = [NSString stringWithCString:value length:value_length];
				[s->typeOfPlay retain];
			} else if (strncmp(key, "rr", 2) == 0) {
// !!!! for later !!!
			} else
				goto unknown_key;

		}
		continue;
	  unknown_key:;
		NSLog(@"Unknown key in seek string\n");
		continue;
	}
	return s;
  error:;
	return nil;
}

- (void) dealloc
{
	[nameFrom release];
	[typeOfPlay release];
	[super dealloc];
}

@end

@implementation SeekGraph

- (void) newSeekFromServer: (int) num description: (const char *) seekInfo
{
	NSEnumerator *keyEnumerator;
	NSNumber *key;
	Seek *s = [Seek seekFromSeekInfo: seekInfo];
	if (s != nil) {
		[seeks setObject: s forKey: [NSNumber numberWithInt: num]];
		keyEnumerator = [seeks keyEnumerator];
		while ((key = [keyEnumerator nextObject]) != nil) {
			s = [seeks objectForKey:key];
			printf("%d: %s\n", [key intValue], [s->nameFrom cString]);
		}
		[seekTable setNeedsDisplay:TRUE];
	} else
		NSLog(@"Error in Seek request");
}

- (void) removeSeekFromServer: (int) num
{
	[seeks removeObjectForKey: [NSNumber numberWithInt: num]];
	[seekTable setNeedsDisplay:TRUE];
}

- (SeekGraph *) init
{
	seeks = [NSMutableDictionary dictionaryWithCapacity:500];
	[seeks retain];
	[super init];
	return self;
}

- (void) dealloc
{
	[seeks release];
	[super dealloc];
}

- (int) numberOfRowsInTableView: (NSTableView *) aTableView
{
	return [seeks count];
}

- (id) tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
{
	NSNumber *key = [[seeks allKeys] objectAtIndex: rowIndex];
	NSString *x = [aTableColumn identifier];
	if ([x compare: @"#"] == 0) {
		return key;
	} else {
		Seek *s = [seeks objectForKey:key];
		if ([x compare: @"Name"] == 0) {
			return s->nameFrom;
		} else if ([x compare: @"Rating"] == 0) {
			return [NSNumber numberWithInt:s->ratingValue];
		} else if ([x compare: @"Type"] == 0) {
			return s->typeOfPlay;
		} else
			return nil;
	}
}

@end
