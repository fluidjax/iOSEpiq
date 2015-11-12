//
//  Story.h
//  IOSEpiq
//
//  Created by Christopher Morris on 11/11/2015.
//  Copyright © 2015 Christopher Morris. All rights reserved.
//

#import <Foundation/Foundation.h>
@class StoryLine;
@class WordList;

@interface Story : NSObject

@property(strong) NSString *title;
@property(strong) WordList *wordList;
@property (assign) BOOL myTurn;
@property(strong) NSString *currentWord;

-(instancetype)initWithTitle:(NSString*)title wordList:(WordList*)wordList;

-(void)addStoryLine:(StoryLine*)storyLine;
-(StoryLine*)storyLineAtIndex:(long)index;
-(long)lineCount;
@end
