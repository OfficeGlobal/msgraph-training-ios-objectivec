//
//  AuthenticationManager.h
//  GraphTutorial
//
//  Copyright © 2019 Microsoft. All rights reserved.
//  Licensed under the MIT license. See LICENSE.txt in the project root for license information.
//

#import <Foundation/Foundation.h>
#import <MSAL/MSAL.h>
#import <MSGraphClientSDK/MSGraphClientSDK.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^GetTokenCompletionBlock)(NSString* _Nullable accessToken, NSError* _Nullable error);

@interface AuthenticationManager : NSObject<MSAuthenticationProvider>

+ (id) instance;
- (void) getTokenInteractivelyWithParentView: (UIViewController*) parentView andCompletionBlock: (GetTokenCompletionBlock)completionBlock;
- (void) getTokenSilentlyWithCompletionBlock: (GetTokenCompletionBlock)completionBlock;
- (void) signOut;
- (void) getAccessTokenForProviderOptions:(id<MSAuthenticationProviderOptions>)authProviderOptions andCompletion:(void (^)(NSString *, NSError *))completion;

@end

NS_ASSUME_NONNULL_END
