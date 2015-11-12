//
//  ViewController.m
//  IOSEpiq
//
//  Created by Christopher Morris on 11/11/2015.
//  Copyright © 2015 Christopher Morris. All rights reserved.
//

#import "ViewController.h"
#import "StoryViewController.h"
#import "Story.h"
#import "StoryLine.h"
#import "WordList.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *storyTitleTextField;

@end

@implementation ViewController


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
    if ([[segue identifier] isEqualToString:@"HomeToStorySegue"]){
        // Get reference to the destination view controller
        StoryViewController *storyViewController = [segue destinationViewController];
        WordList *wordList = [[WordList alloc] initWithFilename:@"wordlist.txt"];
        
        Story *story = [[Story alloc] initWithTitle:self.storyTitleTextField.text wordList:wordList];
        [story setMyTurn:YES];
        
        [storyViewController setStory:story];
    }
}


-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([self.storyTitleTextField.text isEqualToString:@""])return NO;
    return YES;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
