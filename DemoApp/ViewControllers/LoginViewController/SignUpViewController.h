//
//  SignUpViewController.h
//  sample-videochat-webrtc
//
//  Created by urchin on 12/05/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *fullNameTxt;
@property (weak, nonatomic) IBOutlet UITextField *emailTxt;
@property (weak, nonatomic) IBOutlet UITextField *passwordTxt;
@end
