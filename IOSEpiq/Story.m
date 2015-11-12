//
//  Story.m
//  IOSEpiq
//
//  Created by Christopher Morris on 11/11/2015.
//  Copyright © 2015 Christopher Morris. All rights reserved.
//

#import "Story.h"
#import "StoryLine.h"
#import "WordList.h"


@interface Story ()
@property(strong) NSMutableArray *storyLines;
@end

@implementation Story


- (instancetype)initWithTitle:(NSString*)title wordList:(WordList*)wordList{
    self = [super init];
    if (self) {
        self.title = title;
        self.wordList = wordList;
        self.storyLines = [[NSMutableArray alloc] init];
        [self startNewStory];
    }
    return self;
}



-(void)startNewStory{
    [self pickNewRandomWord];
}



-(long)lineCount{
    return [self.storyLines count];
}


-(void)pickNewRandomWord{
    self.currentWord = [self.wordList getRandomWord];
}


-(void)addStoryLine:(StoryLine*)storyLine{
    [self.storyLines addObject:storyLine];
    [self pickNewRandomWord];
}

-(StoryLine*)storyLineAtIndex:(long)index{
    return [self.storyLines objectAtIndex:index];
}



@end
