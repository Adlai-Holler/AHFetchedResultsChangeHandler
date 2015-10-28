//
//  AHFetchedResultsChangeHandler.h
//  FetchedResultsController
//
//  Created by Adlai Holler on 10/27/15.
//  Copyright © 2015 Adlai Holler. All rights reserved.
//

@import Foundation;
@import CoreData;

NS_ASSUME_NONNULL_BEGIN

@class AHFetchedResultsChangeSet;

/**
 This notification is sent synchronously when `controllerDidChangeContent:` is invoked.
 The object of the notification is the `NSFetchedResultsController` instance that owns the results.
 The change set is stored in the userInfo dictionary under `AHFetchedResultsChangeSetUserInfoKey`.
 */
extern NSString *const AHFetchedResultsDidChangeNotification;

/**
 The `AHFetchedResultsChangeSet` sent in AHFetchedResultsDidChangeNotification.
 */
extern NSString *const AHFetchedResultsChangeSetUserInfoKey;

/**
 An object that listens for changes from NSFetchedResultsController and generates AHFetchedResultsChangeSet objects.
 
 How to use:
 Forward all delegate method calls from NSFetchedResultsController to this object.
 Attempting to read any property of this object before `controllerDidChangeContent:`
 will result in an assertion failure.
 */
@interface AHFetchedResultsChangeHandler : NSObject <NSFetchedResultsControllerDelegate>

/**
 An optional delegate that will receive all delegate calls that this object receives.
 */
@property (nonatomic, weak) id<NSFetchedResultsControllerDelegate> forwardingDelegate;

/**
 An block that will be called during controllerDidChangeContent:.
 
 You may also listen for listen for AHFetchedResultsDidChangeNotification.
 */
@property (nullable, nonatomic, copy) void (^resultsDidChange)(NSFetchedResultsController *controller, AHFetchedResultsChangeSet *changeSet);

@end

NS_ASSUME_NONNULL_END
