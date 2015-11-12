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
#import "Qredo.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *storyTitleTextField;
@property (weak, nonatomic) IBOutlet UISwitch *howManyPlayersSwitch;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property QredoClient *qredoClient;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.startButton.enabled=NO;
    
    [QredoClient authorizeWithConversationTypes:@[@"com.qredo.epiq"]
                                 vaultDataTypes:nil
                                      appSecret:@"appSecret"
                                         userId:@"userId"
                                     userSecret:@"userSecret"
                                        options:nil
                              completionHandler:^(QredoClient *clientArg, NSError *error) {
                                  // handle error, store client in property
                                  if (error)                                  {
                                      NSLog(@"Authorize failed with error: %@", error.localizedDescription);
                                      return;
                                  }
                                  self.qredoClient = clientArg;
                                  self.startButton.enabled=YES;
                              }];
    
    
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
    if ([[segue identifier] isEqualToString:@"HomeToStorySegue"]){
        // Get reference to the destination view controller
        StoryViewController *storyViewController = [segue destinationViewController];
        WordList *wordList = [[WordList alloc] initWithFilename:@"wordlist.txt"];
        
        Story *story = [[Story alloc] initWithTitle:self.storyTitleTextField.text wordList:wordList];
        story.qredoClient = self.qredoClient;
        
        story.onePlayerGame = [self.howManyPlayersSwitch isSelected];
        [storyViewController setStory:story];
    }
}


-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([self.storyTitleTextField.text isEqualToString:@""])return NO;
    return YES;
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
