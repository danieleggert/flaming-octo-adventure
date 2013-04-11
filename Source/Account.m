//
//  Account.m
//  AwesomeCodeChallenge
//
//  Created by Daniel Eggert on 11/04/2013.
//  Copyright (c) 2013 Bödewadt. All rights reserved.
//

#import "Account.h"

#import <libkern/OSAtomic.h>
#import <Security/Security.h>



@interface Account ()

@property(nonatomic) BOOL credentialsChanged;

@end



@implementation Account

+ (instancetype)sharedAccount;
{
    static OSSpinLock lock = OS_SPINLOCK_INIT;
    static __weak Account *sharedAccount;
    
    Account *result = nil;
    
    OSSpinLockLock(&lock);
    result = sharedAccount;
    if (result == nil) {
        result = [[self alloc] init];
        sharedAccount = result;
    }
    OSSpinLockUnlock(&lock);
    
    return result;
}

- (id)init;
{
    self = [super init];
    if (self) {
        [self loadCredentials];
    }
    return self;
}

- (void)setUsername:(NSString *)username;
{
    if ((username == _username) ||
        [username isEqualToString:_username])
    {
        return;
    }
    _username = [username copy];
    self.credentialsChanged = YES;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self persistCredentials];
    }];
}

- (void)setPassword:(NSString *)password;
{
    if ((password == _password) ||
        [password isEqualToString:_password])
    {
        return;
    }
    _password = [password copy];
    self.credentialsChanged = YES;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self persistCredentials];
    }];
}

- (BOOL)hasCredentials;
{
    return !(([self.username length] == 0) || ([self.password length] == 0));
}

- (NSData *)keychainItemIdentifier;
{
    return [@"soundcloud.com" dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)loadCredentials;
{
    NSDictionary *query = @{(__bridge id) kSecClass: (__bridge id) kSecClassGenericPassword,
                            (__bridge id) kSecReturnAttributes: @YES,
                            (__bridge id) kSecReturnData: @YES,
                            (__bridge id) kSecAttrGeneric: self.keychainItemIdentifier, };

    CFTypeRef cfattributes = NULL;
    
    OSStatus err = SecItemCopyMatching((__bridge CFDictionaryRef) query,
                                       &cfattributes);
    if (err == noErr) {
        NSDictionary *attributes = (__bridge id) cfattributes;
        NSData *passwordData = attributes[(__bridge id) kSecValueData];
        if (passwordData != nil) {
            self.password = [[NSString alloc] initWithData:passwordData encoding:NSUTF8StringEncoding];
        }
        self.username = attributes[(__bridge id) kSecAttrAccount];
    }
}

- (void)persistCredentials;
{
    if (!self.credentialsChanged) {
        return;
    }
    self.credentialsChanged = NO;
    
    BOOL const shouldDelete = !self.hasCredentials;
    
    if (shouldDelete) {
        NSDictionary *deleteQuery = @{(__bridge id) kSecClass: (__bridge id) kSecClassGenericPassword,
                                      (__bridge id) kSecAttrGeneric: self.keychainItemIdentifier, };
        
        OSStatus err = SecItemDelete((__bridge CFDictionaryRef) deleteQuery);
        if (err == errSecItemNotFound) {
            // Ignore
        } else if (err != noErr) {
            NSLog(@"Failed to delete credentials from keychain. (%d)", (int) err);
        }
    } else {
        NSDictionary *updateQuery = @{(__bridge id) kSecClass: (__bridge id) kSecClassGenericPassword,
                                (__bridge id) kSecAttrGeneric: self.keychainItemIdentifier, };
        
        NSData *passwordData = [self.password dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *attributes = @{(__bridge id) kSecAttrAccount: self.username,
                                     (__bridge id) kSecValueData: passwordData, };
        
        OSStatus err = SecItemUpdate((__bridge CFDictionaryRef) updateQuery,
                                     (__bridge CFDictionaryRef) attributes);
        
        if (err == errSecItemNotFound) {
            NSDictionary *addQuery = @{(__bridge id) kSecClass: (__bridge id) kSecClassGenericPassword,
                                       (__bridge id) kSecAttrAccessible: (__bridge id) kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                       (__bridge id) kSecAttrGeneric: self.keychainItemIdentifier,
                                       (__bridge id) kSecAttrAccount: self.username,
                                       (__bridge id) kSecValueData: passwordData, };
            
            err = SecItemAdd((__bridge CFDictionaryRef) addQuery, NULL);
            if (err != noErr) {
                NSLog(@"Failed to add credentials to keychain. (%d)", (int) err);
            }
        } else if (err != noErr) {
            NSLog(@"Failed to update credentials in keychain. (%d)", (int) err);
        }
    }
}

@end
