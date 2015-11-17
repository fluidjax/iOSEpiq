//
//  ViewController.m
//  IOSEpiq
//
//  Created by Christopher Morris on 11/11/2015.
//  Copyright © 2015 Christopher Morris. All rights reserved.
//

#import "HomeViewController.h"
#import "StoryViewController.h"
#import "StoryListTableViewController.h"
#import "Story.h"
#import "StoryLine.h"
#import "WordList.h"
#import "Qredo.h"


@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UITextField *storyTitleTextField;

@property (weak, nonatomic) IBOutlet UISegmentedControl *howManyPlayers;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property QredoClient *qredoClient;

@end

@implementation HomeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.startButton.enabled=NO;
    self.navigationItem.leftBarButtonItem=nil;
    self.navigationController.navigationBarHidden=YES;

    QredoClientOptions *clientOptions = [[QredoClientOptions alloc] initDefaultPinnnedCertificate];
    if (self.firstRun==YES){
        clientOptions.resetData = YES;
    }else{
        clientOptions.resetData = NO;
    }
    
    [QredoClient initializeWithAppSecret:@"appSecret"
                                  userId:self.username
                                userSecret:self.password
                                 options:clientOptions
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
        
        if (self.howManyPlayers.selectedSegmentIndex==0)story.onePlayerGame = YES;
        [storyViewController setStory:story];
    }else if ([[segue identifier] isEqualToString:@"HomeToStoryList"]){
        StoryListTableViewController *storyListViewController = [segue destinationViewController];
        storyListViewController.qredoClient = self.qredoClient;
    }
}


-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"HomeToStorySegue"] && [self.storyTitleTextField.text isEqualToString:@""])return NO;
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
