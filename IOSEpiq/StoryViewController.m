//
//  StoryViewController.m
//  IOSEpiq
//
//  Created by Christopher Morris on 11/11/2015.
//  Copyright © 2015 Christopher Morris. All rights reserved.
//

#import "StoryViewController.h"
#import "StoryLine.h"
#import "CompletedLineCell.h"
#import "IncompleteLineCell.h"
#import "HeaderCell.h"

#import "WordList.h"

@interface StoryViewController ()


@property (assign) BOOL canAddNewStoryLine;



@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UITextView *storyTextEntryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backGroundBottomConstraint;


@property (weak, nonatomic) IBOutlet UILabel *forceWordLabel;
@property (weak, nonatomic) IBOutlet UILabel *storyTextLabel;



@end

@implementation StoryViewController

-(void)storyDidUpdate{
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
}


-(void)endStory{
    [self.story saveToVault];
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (IBAction)sendButtonPressed:(id)sender {
    NSString *textEntered = self.storyTextEntryView.text;
    
    if ([textEntered containsString:self.story.currentWord]){
        [self.story addNewStoryLine:textEntered forcedWord:self.story.currentWord];
        
        if ([self.story onePlayerGame]==YES){
            [self.storyTextEntryView becomeFirstResponder];
        }
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
    
//    [self.backGroundScrollView setContentOffset:CGPointMake(0,kbSize.height) animated:YES];
//
//
//    [self.storyScrollView setContentOffset:CGPointMake(0,-kbSize.height) animated:YES];
    

    
    
//    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
//    scrollView.contentInset = contentInsets;
//    scrollView.scrollIndicatorInsets = contentInsets;
//    
//    // If active text field is hidden by keyboard, scroll it so it's visible
//    // Your app might not need or want this behavior.
//    CGRect aRect = scrollView.frame;
//    aRect.size.height -= kbSize.height;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification{
  //  UIScrollView *scrollView = self.backGroundScrollView;
//    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
//    scrollView.contentInset = contentInsets;
//    scrollView.scrollIndicatorInsets = contentInsets;
}


@end
