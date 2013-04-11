//
//  LoginViewController.m
//  AwesomeCodeChallenge
//
//  Created by Daniel Eggert on 11/04/2013.
//  Copyright (c) 2013 Bödewadt. All rights reserved.
//

#import "LoginViewController.h"

#import "SCAPI.h"
#import "SCSoundCloud+Private.h"
#import "NSAttributedString+Helpers.h"
#import "Account.h"



@interface LoginViewController ()

@property(nonatomic, weak) UITextField *usernameField;
@property(nonatomic, weak) UITextField *passwordField;
@property(nonatomic, weak) UIButton *button;
@property(nonatomic, weak) UILabel *statusLabel;
@property(nonatomic, weak) UIActivityIndicatorView *activityIndicator;
@property(nonatomic) BOOL userInterfaceEnabled;

@property(nonatomic, copy) NSString *username;
@property(nonatomic, copy) NSString *password;

@end



@interface LoginViewController (TextFieldDelegate) <UITextFieldDelegate>
@end



@implementation LoginViewController

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCSoundCloudAccountDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCSoundCloudDidFailToRequestAccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)loadView;
{
    [super loadView];
    
    UIView *view = self.view;
    view.backgroundColor = [UIColor colorWithHue:0.066 saturation:1 brightness:1 alpha:1];
    
    UILabel *userLabel = [[UILabel alloc] init];
    userLabel.translatesAutoresizingMaskIntoConstraints = NO;
    userLabel.backgroundColor = [UIColor clearColor];
    userLabel.attributedText = [NSLocalizedString(@"LOGIN_USERNAME_LABEL", @"") attributedStringWithAttributes:self.labelAttributes];
    [view addSubview:userLabel];
    UITextField *userField = [[UITextField alloc] init];
    userField.translatesAutoresizingMaskIntoConstraints = NO;
    userField.delegate = self;
    userField.keyboardType = UIKeyboardTypeEmailAddress;
    userField.autocorrectionType = UITextAutocorrectionTypeNo;
    userField.backgroundColor = [UIColor whiteColor];
    userField.borderStyle = UITextBorderStyleBezel;
    userField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [view addSubview:userField];
    self.usernameField = userField;
    
    UILabel *passwordLabel = [[UILabel alloc] init];
    passwordLabel.translatesAutoresizingMaskIntoConstraints = NO;
    passwordLabel.attributedText = [NSLocalizedString(@"LOGIN_PASSWORD_LABEL", @"") attributedStringWithAttributes:self.labelAttributes];
    passwordLabel.backgroundColor = [UIColor clearColor];
    [view addSubview:passwordLabel];
    UITextField *passwordField = [[UITextField alloc] init];
    passwordField.translatesAutoresizingMaskIntoConstraints = NO;
    passwordField.secureTextEntry = YES;
    passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordField.backgroundColor = [UIColor whiteColor];
    passwordField.borderStyle = UITextBorderStyleBezel;
    passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [view addSubview:passwordField];
    self.passwordField = passwordField;
    
    UIButton *login = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    login.translatesAutoresizingMaskIntoConstraints = NO;
    [login setAttributedTitle:[NSLocalizedString(@"LOGIN_LOGIN_BUTTON_TITLE", @"") attributedStringWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor blackColor]}] forState:UIControlStateNormal];
    [login setAttributedTitle:[NSLocalizedString(@"LOGIN_LOGIN_BUTTON_TITLE", @"") attributedStringWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor lightGrayColor]}] forState:UIControlStateDisabled];
    [login addTarget:self action:@selector(loginButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:login];
    self.button = login;
    
    UILabel *status = [[UILabel alloc] init];
    status.translatesAutoresizingMaskIntoConstraints = NO;
    status.text = @"";
    status.backgroundColor = [UIColor clearColor];
    status.numberOfLines = 2;
    [view addSubview:status];
    self.statusLabel = status;
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activity.translatesAutoresizingMaskIntoConstraints = NO;
    activity.hidesWhenStopped = YES;
    [activity stopAnimating];
    [view addSubview:activity];
    self.activityIndicator = activity;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(userLabel, userField, passwordLabel, passwordField, login, status, activity);
    NSDictionary *metrics = nil;
    
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[userLabel]-|" options:0 metrics:metrics views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[userField]-|" options:0 metrics:metrics views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[passwordLabel]-|" options:0 metrics:metrics views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[passwordField]-|" options:0 metrics:metrics views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[login]-|" options:0 metrics:metrics views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[status]-|" options:0 metrics:metrics views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[userLabel][userField(30)]-(20)-[passwordLabel][passwordField(30)]-(24)-[login]-(24)-[status(48)]-[activity]" options:0 metrics:metrics views:views]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:activity attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
        NSLog(@"preparedURL: %@", preparedURL);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountDidChange:) name:SCSoundCloudAccountDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailToRequestAccess:) name:SCSoundCloudDidFailToRequestAccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:self.usernameField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:self.passwordField];
    
    Account *account = [Account sharedAccount];
    self.usernameField.attributedText = [account.username attributedStringWithAttributes:self.textFieldAttributes];
    if (account.hasCredentials) {
        self.passwordField.text = account.password;
        //[self loginButtonTapped:self.button];
    }
    self.userInterfaceEnabled = YES;
}

- (void)loginButtonTapped:(id)sender;
{
    if (![self.view endEditing:NO]) {
        return;
    }
    
    self.userInterfaceEnabled = NO;
    self.statusLabel.attributedText = nil;
    
    self.username = self.usernameField.text;
    self.password = self.passwordField.text;

    [[SCSoundCloud shared] requestAccessWithUsername:self.username
                                            password:self.password];
    [self.activityIndicator startAnimating];
}

- (BOOL)userInterfaceEnabled;
{
    return self.usernameField.enabled;
}

- (void)setUserInterfaceEnabled:(BOOL)enabled;
{
    self.usernameField.enabled = enabled;
    self.passwordField.enabled = enabled;
    self.button.enabled = enabled && self.shouldEnableLoginButton;
}

- (BOOL)shouldEnableLoginButton;
{
    return ((0 < [self.usernameField.text length]) &&
            (0 < [self.passwordField.text length]));
}

- (NSDictionary *)labelAttributes;
{
    return @{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor whiteColor]};
}

- (NSDictionary *)textFieldAttributes;
{
    return @{NSFontAttributeName: [UIFont systemFontOfSize:16]};
}

- (NSDictionary *)statusAttributes;
{
    return @{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor whiteColor]};
}

- (void)accountDidChange:(NSNotification *)note;
{
    [self.activityIndicator stopAnimating];
    
    if (([SCSoundCloud account] != nil) &&
        (0 < [self.username length]) &&
        (0 < [self.password length]))
    {
        Account *account = [Account sharedAccount];
        account.username = self.username;
        account.password = self.password;
    }
}

- (void)didFailToRequestAccess:(NSNotification *)note;
{
    NSLog(@"%@", note);

    [self.activityIndicator stopAnimating];
    
    self.userInterfaceEnabled = YES;
    self.statusLabel.attributedText = [NSLocalizedString(@"Login Failed. Bummer.", @"") attributedStringWithAttributes:self.statusAttributes];

    self.username = nil;
    self.password = nil;
}

@end



@implementation LoginViewController (TextFieldDelegate)

- (void)textFieldTextDidChange:(NSNotification *)note;
{
    self.button.enabled = self.userInterfaceEnabled && self.shouldEnableLoginButton;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    textField.typingAttributes = self.textFieldAttributes;
}

@end
