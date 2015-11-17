//
//  Story.h
//  IOSEpiq
//
//  Created by Christopher Morris on 11/11/2015.
//  Copyright © 2015 Christopher Morris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Qredo.h"
#import "QredoVault.h"
#import "QredoRendezvous.h"
#import "QredoConversation.h"


@protocol StoryProtocol
@required
-(void)storyDidUpdate;
@end


@class StoryLine;
@class WordList;

@interface Story : NSObject <QredoRendezvousObserver, QredoConversationObserver>

@property(strong) NSString *title;
@property(strong) WordList *wordList;
@property(strong) NSString *currentWord;
@property(assign) BOOL onePlayerGame;
@property(assign) BOOL storyEnded;
@property(assign) int nextAvailableStoreLineIndex;
@property QredoClient *qredoClient;
@property(strong) id<StoryProtocol> delegate;


-(instancetype)initWithTitle:(NSString*)title wordList:(WordList*)wordList;

-(NSMutableAttributedString*)buildAttributedTextStory;
-(void)addNewLocallyEnteredStoryLine:(NSString*)storyLineText forcedWord:(NSString*)forcedWord;
-(StoryLine*)storyLineAtIndex:(long)index;
-(long)lineCount;
-(BOOL)isMyTurn;
-(void)saveToVault;
-(void)prepareQredoConnections;
-(void)createOrJoinRendezvous;
-(void)sendEndStoryMessage;

@end
