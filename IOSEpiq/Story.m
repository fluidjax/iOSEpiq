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
@property(assign) BOOL storyOwner;

@property QredoRendezvous *rendezvous;
@property QredoConversation *conversation;
@end

@implementation Story


#pragma mark -
#pragma mark Public Methods

- (instancetype)initWithTitle:(NSString*)title wordList:(WordList*)wordList{
    self = [super init];
    if (self) {
        self.title = title;
        self.wordList = wordList;
        self.storyLines = [[NSMutableArray alloc] init];
        self.storyEnded = NO;
        [self startNewStory];
        self.nextAvailableStoreLineIndex = 0;
    }
    return self;
}


-(void)prepareQredoConnections{
    if (self.onePlayerGame==NO)[self createOrJoinRendezvous];
}


-(NSMutableAttributedString*)buildAttributedTextStory{
    NSMutableAttributedString *returnVal = [[NSMutableAttributedString alloc] init];
    NSAttributedString *space = [[NSAttributedString alloc] initWithString:@" "];
    for (int i=0;i<[self lineCount];i++){
        StoryLine *storyLine = [self storyLineAtIndex:i];
        
        if ([storyLine respondsToSelector:@selector(attributedText)])[returnVal appendAttributedString:[storyLine attributedText]];
        
        [returnVal appendAttributedString:space];
    }
    return returnVal;
}


-(void)addNewLocallyEnteredStoryLine:(NSString*)storyLineText forcedWord:(NSString*)forcedWord{
    StoryLine *storyLine = [[StoryLine alloc] initWithText:storyLineText forcedWord:forcedWord index:self.nextAvailableStoreLineIndex];
    self.nextAvailableStoreLineIndex++;
    if ([self isTwoPlayerGame])[self sendStoryLineToConversation:storyLine];
    [self.storyLines addObject:storyLine];
    [self pickNewRandomWord];
}


-(BOOL)isMyTurn{
    if (self.onePlayerGame==YES)return YES;
    if (self.storyOwner==YES && (self.lineCount % 2==0))return YES;
    if (self.storyOwner==NO  && (self.lineCount % 2==1))return YES;
    return NO;
}


#pragma mark -
#pragma mark Private Methods

-(void)sendPendingMessageToConversation{
    for (int i=0;i<[self lineCount];i++){
        StoryLine *storyLine = [self storyLineAtIndex:i];
        if (storyLine.messageSentToConversation==NO){
            [self sendStoryLineToConversation:storyLine];
        }
    }
}


-(void)updateStoryWithAllSentMessages{
    [self.conversation enumerateSentMessagesUsingBlock:^(QredoConversationMessage *message, BOOL *stop) {
        NSDictionary *summaryVaules = message.summaryValues;
        NSString *storyLineText = [[NSString alloc] initWithData: message.value encoding: NSUTF8StringEncoding];
        NSString *forcedWord    = summaryVaules[@"word"];
        int index               = [summaryVaules[@"index"] intValue];
        NSLog(@"Add story Line %@ %i",storyLineText, index);
        StoryLine *storyLine = [self addRemoteStoryLine:storyLineText forcedWord:forcedWord index:index];
        [self checkForStoryEnd:storyLine];
    } since:nil completionHandler:^(NSError *error) {
        if (error)NSLog(@"Error downloading existing conversation messages %@", error);
        [self.delegate storyDidUpdate];
    }];
    
}


-(void)updateStoryWithAllReceivedMessages{
    [self.conversation enumerateReceivedMessagesUsingBlock:^(QredoConversationMessage *message, BOOL *stop) {
        NSDictionary *summaryVaules = message.summaryValues;
        NSString *storyLineText = [[NSString alloc] initWithData: message.value encoding: NSUTF8StringEncoding];
        NSString *forcedWord    = summaryVaules[@"word"];
        int index               = [summaryVaules[@"index"] intValue];
        NSLog(@"Add story Line %@ %i",storyLineText, index);
        StoryLine *storyLine = [self addRemoteStoryLine:storyLineText forcedWord:forcedWord index:index];
        [self checkForStoryEnd:storyLine];
    } since:nil completionHandler:^(NSError *error) {
        if (error)NSLog(@"Error downloading existing conversation messages %@", error);
        [self updateStoryWithAllSentMessages];
    }];
}


-(NSString*)santizedStoryName{
    //we could strip space here to make sure the players more easily connect using the same tag
    return self.title;
}




-(void)buildTestStory{
    for (int i=0;i<100;i++){
        [self addNewLocallyEnteredStoryLine:@"The quick brown fox jumps over the Lazy dog." forcedWord:@"fox"];
    }
}

-(void)sendEndStoryMessage{
    [self addNewLocallyEnteredStoryLine:@"The End" forcedWord:@"The End"];
    self.storyEnded = YES;
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

     
-(StoryLine*)addRemoteStoryLine:(NSString*)storyLineText forcedWord:(NSString*)forcedWord index:(int)index{
    StoryLine *storyLine = [[StoryLine alloc] initWithText:storyLineText forcedWord:forcedWord index:index];
    NSLog(@"Adding remote story line '%@'  with forcedWord '%i'", storyLine.text, index);
    
    if (index>[self.storyLines count]){
        for (int i=(int)[self.storyLines count];i<index;i++){
            [self.storyLines insertObject:[NSNull null] atIndex:i];
        }
    }
    
    [self.storyLines setObject:storyLine atIndexedSubscript:index];
    if (self.nextAvailableStoreLineIndex<=index)self.nextAvailableStoreLineIndex = index+1;
    return storyLine;
}
     

-(StoryLine*)storyLineAtIndex:(long)index{
    return [self.storyLines objectAtIndex:index];
}


-(BOOL)isTwoPlayerGame{
    return !self.onePlayerGame;
}


-(void)checkForStoryEnd:(StoryLine*)storyLine{
    if ([storyLine.text isEqualToString:@"The End"] && [storyLine.forcedWord isEqualToString:@"The End"]){
        self.storyEnded = YES;
    }
}

#pragma mark -
#pragma mark QredoRendezvousObserver methods

/** Called when a new response is received */
- (void)qredoRendezvous:(QredoRendezvous*)rendezvous didReceiveReponse:(QredoConversation *)conversation{
    self.conversation = conversation;
    [conversation addConversationObserver: self];
    [self sendPendingMessageToConversation];
    NSLog(@"Incoming Rendezvous Connection made");
}


#pragma mark -
#pragma mark QredoConversationObserver methods

/** Called when a onversation receives a new message */
- (void)qredoConversation:(QredoConversation *)conversation didReceiveNewMessage:(QredoConversationMessage *)message{
    // Process an incoming message
    NSDictionary *summaryVaules = message.summaryValues;
    NSString *storyLineText = [[NSString alloc] initWithData: message.value encoding: NSUTF8StringEncoding];
    NSString *forcedWord    = summaryVaules[@"word"];
    int index               = [summaryVaules[@"index"] intValue];
    StoryLine *storyLine = [self addRemoteStoryLine:storyLineText forcedWord:forcedWord index:index];
    [self checkForStoryEnd:storyLine];
    [self.delegate storyDidUpdate];
    NSLog(@"Conversation received a new remote message");
}


#pragma mark -
#pragma mark Qredo Access Methods 

-(void)saveToVault{
    NSDictionary *item1SummaryValues = @{@"StoryTitle": self.title};
    NSString *text = [[self buildAttributedTextStory] string];
    QredoVaultItemMetadata *metadata =  [QredoVaultItemMetadata vaultItemMetadataWithDataType:@"com.qredo.test"
                                                                                  accessLevel:0
                                                                                summaryValues:item1SummaryValues];
    
    QredoVaultItem *item1 =[QredoVaultItem vaultItemWithMetadata:metadata value:[text dataUsingEncoding:NSUTF8StringEncoding]];
    [self.qredoClient.defaultVault putItem:item1 completionHandler:^(QredoVaultItemMetadata  *newVaultItemMetadata, NSError *error){
        if (!error) {
            NSLog(@"Story added to vault");
        }
    }];
}



-(void)createOrJoinRendezvous{
    //Player A creates a new rendezvous
    //Player B will fail to create because if already exsitis, and so falls back to joining an existing Rendezvous
    self.rendezvous = nil;
    self.conversation = nil;
    
    
    QredoRendezvousConfiguration *rendezvousConfiguration =
    [[QredoRendezvousConfiguration alloc] initWithConversationType: @"com.qredo.epiq~"
                                                   durationSeconds: 0
                                          isUnlimitedResponseCount: true ];
    
    [self.qredoClient createAnonymousRendezvousWithTag: [self santizedStoryName]
                                         configuration: rendezvousConfiguration
                                     completionHandler:^(QredoRendezvous *rendezvous, NSError *error){
                                         if (error){
                                             if (error.code==3003){
                                                 //this rendezvous already exists so connect to it
                                                 //check if its an exsiting one of ours
                                                  NSLog(@"Rendezvous with Tag %@ already exsits", [self santizedStoryName]);
                                                 [self getExsitingRendezvousWithThisStoryTag];
                                             }else{
                                                 NSLog(@"Error creating Rendezvous: %@", error.localizedDescription);
                                             }
                                             return;
                                         }else{
                                             NSLog(@"New Rendezvous created successsfully!");
                                             self.storyOwner = YES;
                                             self.rendezvous = rendezvous;
                                             [self.rendezvous addRendezvousObserver:self];
                                             [self.delegate storyDidUpdate];
                                         }
                                     }
     ];
    
}






-(void)getExsitingRendezvousWithThisStoryTag{
    [self.qredoClient fetchRendezvousWithTag:[self santizedStoryName] completionHandler:^(QredoRendezvous *rendezvous, NSError *error) {
        if (rendezvous){
            NSLog(@"Connected to the exsiting rendezvous");
            [self getConversationMetadataWithRendezvous:rendezvous];
        }else{
            NSLog(@"No previous connection to this rendezvous in vault");
            [self respondToRendezvousByTag];
        }
    }];
}



-(void)getConversationMetadataWithRendezvous:(QredoRendezvous *)rendezvous{
    __block QredoConversationMetadata *matchedConversationMetadata;
    
    [self.qredoClient enumerateConversationsWithBlock:^(QredoConversationMetadata *conversationMetadata, BOOL *stop) {
        matchedConversationMetadata = conversationMetadata;
        *stop=YES;
    } completionHandler:^(NSError *error) {
        if (error){
            NSLog(@"Error enumerating conversations");
        }else{
            if (matchedConversationMetadata){
                NSLog(@"Found a conversationRef for the rendezvous");
                [self getConversationWithRef:matchedConversationMetadata.conversationRef];
            }else{
                //no conversation found - start a new one conversation by tag
                NSLog(@"No conversations for the rendezvous");
                [self respondToRendezvousByTag];
            }
        }
        
    }];
}

-(void)getConversationWithRef:(QredoConversationRef *)conversationRef{
    [self.qredoClient fetchConversationWithRef:conversationRef completionHandler:^(QredoConversation *conversation, NSError *error) {
        NSLog(@"Got conversation for conversationRef");
        self.conversation = conversation;
        [self.conversation addConversationObserver:self];
        if (self.conversation.metadata.amRendezvousOwner==YES)self.storyOwner=YES;
        [self updateStoryWithAllReceivedMessages];
        
    }];
}


-(void)respondToRendezvousByTag{
    //Player B joins an existing Rendezvous
    [self.qredoClient respondWithTag:[self santizedStoryName]
                   completionHandler:^(QredoConversation *conversation, NSError *error) {
                       if (error){
                           NSLog(@"Failed to join rendezvous with error: %@", error.localizedDescription);
                           return;
                       }
                       self.conversation = conversation;
                       self.storyOwner = NO;
                       NSLog(@"Join another users rendezvous with tag %@", [self santizedStoryName]);
                       [conversation addConversationObserver: self];
                   }
     ];
}



-(void)sendStoryLineToConversation:(StoryLine*)storyLine{
    //Send a storyLine if we have a conversation
    if (!self.conversation){
        NSLog(@"Player 2 has not connected yet - waiting for connection before sending storyline");
        return;
    }
    
    NSDate *currentDateTime = [NSDate date];
    NSDictionary *messageSummaryValues = @{@"index": [NSNumber numberWithInt:storyLine.index],
                                           @"word": storyLine.forcedWord,
                                           @"date": currentDateTime};
    QredoConversationMessage *conversationMessage = [[QredoConversationMessage alloc] initWithValue:[storyLine.text dataUsingEncoding:NSUTF8StringEncoding]
                                                                                           dataType: @"com.qredo.plaintext"
                                                                                      summaryValues: messageSummaryValues];
    
    if (conversationMessage){
        [self.conversation publishMessage: conversationMessage completionHandler: ^(QredoConversationHighWatermark *messageHighWatermark, NSError *error) {
            if (error){
                NSLog(@"Posting message failed with error: %@", error.localizedDescription);
            }
            NSLog(@"Posted message: '%@'",storyLine.text);
        }];
    }
}


@end
