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
@property (weak, nonatomic) IBOutlet UITextView *storyViewTextView;



@end

@implementation StoryViewController

-(void)storyDidUpdate{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshScreen];
    });
}


-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=NO;
    [self registerForKeyboardNotifications];
    self.story.delegate = self;
    [self.story prepareQredoConnections];
    
    self.navigationItem.title = self.story.title;
    self.navigationItem.leftBarButtonItem = nil;
    UIBarButtonItem *endStoryButton = [[UIBarButtonItem alloc] initWithTitle:@"End" style:UIBarButtonItemStylePlain
                                                                      target:self action:@selector(endStoryPressed)];
    self.navigationItem.rightBarButtonItem = endStoryButton;
    [self refreshScreen];
}


- (IBAction)sendButtonPressed:(id)sender {
    NSString *textEntered = self.storyTextEntryView.text;
    
    if ([self wordHasBeenUsed]){
        [self.story addNewLocallyEnteredStoryLine:textEntered forcedWord:self.story.currentWord];
        [self refreshScreen];
    }else{
        [self showWordNotUsedAlert];
        
    }
}

-(void)endStoryPressed{
    [self.story sendEndStoryMessage];
    [self storyDidUpdate];
}


-(void)refreshScreen{
    self.storyViewTextView.attributedText = [self.story buildAttributedTextStory];
    
    if (self.story.storyEnded==YES) {
        self.forceWordLabel.text = @"Story Complete";
        self.textEntryBackgroundView.hidden=YES;
        [self.story saveToVault];
        self.navigationItem.rightBarButtonItem = nil;
    }else{
        self.forceWordLabel.text = self.story.currentWord;
        self.storyTextEntryView.text = @"";
        
        if ([self.story isMyTurn]){
            self.forceWordLabel.text = self.story.currentWord;
            self.navigationItem.rightBarButtonItem.enabled=YES;
            self.textEntryBackgroundView.hidden=NO;
            [self.storyTextEntryView becomeFirstResponder];
        }else{
            self.forceWordLabel.text = @"Waiting. . . ";
            self.navigationItem.rightBarButtonItem.enabled=NO;
            self.textEntryBackgroundView.hidden=YES;
        }
    }
    [self scrollToTheEndOfTheStoryView];
    
}


-(void)checkForEndOfStory{
    if (self.story.storyEnded==YES){
        self.textEntryBackgroundView.hidden=YES;
        [self.story saveToVault];
    }
}


-(void)scrollToTheEndOfTheStoryView{
    NSRange range = NSMakeRange(self.storyViewTextView.text.length - 1, 1);
    [self.storyViewTextView scrollRangeToVisible:range];
}


-(BOOL)wordHasBeenUsed{
    NSString *textEntered = self.storyTextEntryView.text;
    return [textEntered rangeOfString:self.story.currentWord options:NSCaseInsensitiveSearch].location != NSNotFound;
    
}


-(void)showWordNotUsedAlert{
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
