//
//  AHFetchedResultsChangeHandler.m
//  FetchedResultsController
//
//  Created by Adlai Holler on 10/27/15.
//  Copyright © 2015 Adlai Holler. All rights reserved.
//

#import "AHFetchedResultsChangeHandler.h"
#import "AHFetchedResultsChangeSet.h"

NS_ASSUME_NONNULL_BEGIN

NSString *const AHFetchedResultsDidChangeNotification = @"AHFetchedResultsDidChangeNotification";

NSString *const AHFetchedResultsChangeSetUserInfoKey = @"AHFetchedResultsChangeSetUserInfoKey";

@interface AHFetchedResultsChangeSet (Private) <NSFetchedResultsControllerDelegate>
@end

@interface AHFetchedResultsChangeHandler () {
    struct {
        BOOL delegateDidChangeContent: 1;
        BOOL delegateWillChangeContent: 1;
        BOOL delegateDidChangeObject: 1;
        BOOL delegateDidChangeSection: 1;
        BOOL delegateSectionIndexTitle: 1;
    } _flags;
}

@property (nullable, nonatomic, strong) AHFetchedResultsChangeSet *currentChangeSet;

@end

@implementation AHFetchedResultsChangeHandler

#pragma mark Forwarding Delegate

/**
 Update our delegate flags.
 */
- (void)setForwardingDelegate:(nullable id<NSFetchedResultsControllerDelegate>)forwardingDelegate {
    if (_forwardingDelegate == forwardingDelegate) { return; }
    
    _forwardingDelegate = forwardingDelegate;
    
    _flags.delegateDidChangeContent = [forwardingDelegate respondsToSelector:@selector(controllerDidChangeContent:)];
    _flags.delegateWillChangeContent = [forwardingDelegate respondsToSelector:@selector(controllerDidChangeContent:)];
    _flags.delegateDidChangeObject = [forwardingDelegate respondsToSelector:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)];
    _flags.delegateDidChangeSection = [forwardingDelegate respondsToSelector:@selector(controller:didChangeSection:atIndex:forChangeType:)];
    _flags.delegateSectionIndexTitle = [forwardingDelegate respondsToSelector:@selector(controller:sectionIndexTitleForSectionName:)];
}

#pragma mark NSObject

/**
 Pretend we don't respond to `sectionIndexTitleForSectionName:` unless our forwarding delegate does.
 */
- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(controller:sectionIndexTitleForSectionName:)) {
        return _flags.delegateSectionIndexTitle;
    }
    return [super respondsToSelector:aSelector];
}

@end

@implementation AHFetchedResultsChangeHandler (NSFetchedResultsControllerDelegateImpl)

- (void)computeChanges {
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    NSAssert(_currentChangeSet == nil, @"Received controllerWillChangeContent: without finishing current change set.");
    _currentChangeSet = [AHFetchedResultsChangeSet new];
    
    [_currentChangeSet controllerWillChangeContent:controller];
    
    if (_flags.delegateWillChangeContent) {
        [_forwardingDelegate controllerWillChangeContent:controller];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {

    [_currentChangeSet controller:controller didChangeSection:sectionInfo atIndex:sectionIndex forChangeType:type];
    
    if (_flags.delegateDidChangeSection) {
        [_forwardingDelegate controller:controller didChangeSection:sectionInfo atIndex:sectionIndex forChangeType:type];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath {
    
    [_currentChangeSet controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];

    if (_flags.delegateDidChangeObject) {
        [_forwardingDelegate controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    AHFetchedResultsChangeSet *changeSet = _currentChangeSet;
    [changeSet controllerDidChangeContent:controller];
    
    // Notify listeners
    if (_resultsDidChange != nil) {
        _resultsDidChange(controller, changeSet);
    }
    
    NSDictionary *userInfo = @{ AHFetchedResultsChangeSetUserInfoKey: changeSet };
    [NSNotificationCenter.defaultCenter postNotificationName:AHFetchedResultsDidChangeNotification object:controller userInfo:userInfo];
    
    _currentChangeSet = nil;
    
    // Notify forwarding delegate
    if (_flags.delegateDidChangeContent) {
        [_forwardingDelegate controllerDidChangeContent:controller];
    }
}

- (nullable NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName {
    if (_flags.delegateSectionIndexTitle) {
        return [_forwardingDelegate controller:controller sectionIndexTitleForSectionName:sectionName];
    } else {
        // We shouldn't get here, since we returned NO for `respondsToSelector` but we got it covered anyway
        return [[sectionName substringToIndex:1] uppercaseString];
    }
}

@end

NS_ASSUME_NONNULL_END
