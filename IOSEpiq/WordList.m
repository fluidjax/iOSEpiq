//
//  WordList.m
//  IOSEpiq
//
//  Created by Christopher Morris on 11/11/2015.
//  Copyright © 2015 Christopher Morris. All rights reserved.
//

#import "WordList.h"

@interface WordList ()
@property(strong) NSArray<NSString*> *wordlist;

@end

@implementation WordList



- (instancetype)initWithFilename:(NSString*)filename{
    self = [super init];
    if (self) {
        [self loadWordList:filename];
    }
    return self;
}

-(NSString*)getRandomWord{
    long maxVal = [self.wordlist count];
    long randomValue = arc4random()%maxVal;
    return [self.wordlist objectAtIndex:randomValue];
}

-(void)loadWordList:(NSString*)filename{
    NSMutableArray *words = [[NSMutableArray alloc] init];
    NSString* fileRoot = [[NSBundle mainBundle] pathForResource:@"wordlist" ofType:@"txt"];
    FILE *file = fopen([fileRoot UTF8String], "r");
    char buffer[256];
    while (fgets(buffer, 256, file) != NULL){
        NSString* result = [NSString stringWithUTF8String:buffer];
        [words addObject:[result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
    self.wordlist = words;
}

@end
