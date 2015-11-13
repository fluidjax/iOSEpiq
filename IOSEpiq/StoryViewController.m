//
//  StoryViewController.m
//  IOSEpiq
//
//  Created by Christopher Morris on 11/11/2015.
//  Copyright © 2015 Christopher Morris. All rights reserved.
//

#import "StoryViewController.h"
#import "StoryLine.h"
#import "WordList.h"

@interface StoryViewController ()


@property (assign) BOOL canAddNewStoryLine;



@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UITextView *storyTextEntryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backGroundBottomConstraint;

@property (weak, nonatomic) IBOutlet UIView *textEntryBackgroundView;

@property (weak, nonatomic) IBOutlet UILabel *forceWordLabel;
@property (weak, nonatomic) IBOutlet UILabel *storyTextLabel;



@end

@implementation StoryViewController

-(void)storyDidUpdate{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshScreen];
    });
}


-(void)viewDidLoad{
    self.navigationController.navigationBarHidden=NO;
    [self registerForKeyboardNotifications];
    self.story.delegate = self;
    if (self.story.onePlayerGame==NO)[self.story createOrJoinRendezvous];
    self.navigationItem.title = self.story.title;
    self.navigationItem.leftBarButtonItem = nil;
    UIBarButtonItem *endStoryButton = [[UIBarButtonItem alloc] initWithTitle:@"End" style:UIBarButtonItemStylePlain
                                                                      target:self action:@selector(endStory)];
    self.navigationItem.rightBarButtonItem = endStoryButton;
    [self refreshScreen];
}


-(void)endStory{
    [self.story saveToVault];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)refreshScreen{
    self.forceWordLabel.text = self.story.currentWord;
    self.storyTextLabel.attributedText = [self.story buildAttributedTextStory];
    self.storyTextEntryView.text = @"";
    
    if ([self.story myTurn]){
        self.forceWordLabel.text = self.story.currentWord;
        self.textEntryBackgroundView.hidden=NO;
    }else{
        self.forceWordLabel.text = @"Waiting. . . ";
        self.textEntryBackgroundView.hidden=YES;
    }
    
}


- (IBAction)sendButtonPressed:(id)sender {
    NSString *textEntered = self.storyTextEntryView.text;
    
    if ([textEntered containsString:self.story.currentWord]){
        [self.story addNewStoryLine:textEntered forcedWord:self.story.currentWord];
        
        if ([self.story onePlayerGame]==YES){
            [self.storyTextEntryView becomeFirstResponder];
        }
        [self refreshScreen];
    }else{
        NSString *message = [NSString stringWithFormat:@"The line of your story must\n include the word '%@'",self.story.currentWord];
        
        UIAlertController * missingWordAlert=   [UIAlertController
                                      alertControllerWithTitle:@"Word Missing!"
                                      message:message
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [missingWordAlert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        [missingWordAlert addAction:ok];
        
        [self presentViewController:missingWordAlert animated:YES completion:nil];
        
    }
}




#pragma Handle Keyboard Display/Hide
// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}


- (void)keyboardWillShow:(NSNotification*)aNotification{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.backGroundBottomConstraint.constant =kbSize.height;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification{
    self.backGroundBottomConstraint.constant =0;
}

@end
