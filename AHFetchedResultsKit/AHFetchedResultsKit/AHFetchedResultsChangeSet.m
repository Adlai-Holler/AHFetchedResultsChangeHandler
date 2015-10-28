//
//  AHFetchedResultsChangeSet.m
//  FetchedResultsController
//
//  Created by Adlai Holler on 10/27/15.
//  Copyright © 2015 Adlai Holler. All rights reserved.
//

#import "AHFetchedResultsChangeSet.h"

NS_ASSUME_NONNULL_BEGIN

@interface AHFetchedResultsChangeSet () {
    struct {
        BOOL delegateDidChangeContent: 1;
        BOOL delegateWillChangeContent: 1;
        BOOL delegateDidChangeObject: 1;
        BOOL delegateDidChangeSection: 1;
        BOOL delegateSectionIndexTitle: 1;
        BOOL haveReceivedWillChange: 1;
        BOOL haveReceivedDidChange: 1;
    } _flags;
}

@property (nonatomic, strong, readonly) NSMutableIndexSet *m_deletedSections;
@property (nonatomic, strong, readonly) NSMutableIndexSet *m_insertedSections;
@property (nonatomic, strong, readonly) NSMutableArray<NSIndexPath *> *m_fromIndexPaths;
@property (nonatomic, strong, readonly) NSMutableArray<NSIndexPath *> *m_toIndexPaths;
@property (nonatomic, strong, readonly) NSMutableArray<NSIndexPath *> *m_updatedIndexPaths;
@property (nonatomic, strong, readonly) NSMutableArray<NSIndexPath *> *m_deletedIndexPaths;
@property (nonatomic, strong, readonly) NSMutableArray<NSIndexPath *> *m_insertedIndexPaths;

@end

@implementation NSIndexPath (InverseComparison)

- (NSComparisonResult)ah_inverseCompare:(NSIndexPath *)otherIndexPath {
    return [otherIndexPath compare:self];
}

@end

@implementation AHFetchedResultsChangeSet

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (!self) { return nil; }
    
    static NSIndexSet *placeholderIndexSet;
    static NSArray<NSIndexPath *> *placeholderArray;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        placeholderIndexSet = [NSIndexSet new];
        placeholderArray = [NSArray new];
    });
    
    _insertedSections = placeholderIndexSet;
    _deletedSections = placeholderIndexSet;
    
    _deletedIndexPaths = placeholderArray;
    _insertedIndexPaths = placeholderArray;
    _updatedIndexPaths = placeholderArray;
    
    _m_insertedSections = [NSMutableIndexSet new];
    _m_deletedSections = [NSMutableIndexSet new];
    _m_fromIndexPaths = [NSMutableArray new];
    _m_toIndexPaths = [NSMutableArray new];
    _m_insertedIndexPaths = [NSMutableArray new];
    _m_deletedIndexPaths = [NSMutableArray new];
    _m_updatedIndexPaths = [NSMutableArray new];
    return self;
}

#pragma mark - Computing Changes

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    NSAssert(!_flags.haveReceivedWillChange, @"Received controllerWillChangeContent: twice.");
    _flags.haveReceivedWillChange = YES;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    NSAssert(_flags.haveReceivedWillChange, @"Received a change without controllerWillChangeContent:");
    
    switch (type) {
        case NSFetchedResultsChangeDelete:
            [_m_deletedSections addIndex:sectionIndex];
            break;
        case NSFetchedResultsChangeInsert:
            [_m_insertedSections addIndex:sectionIndex];
            break;
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath {
    NSAssert(_flags.haveReceivedWillChange, @"Received a change without controllerWillChangeContent:");
    
    // NSFRC sometimes sends invalid change type 0.
    if (type == 0) {
        return;
    }
    // NSFRC sometimes reports updates as moves from & to the same index path
    if (type == NSFetchedResultsChangeMove && [newIndexPath isEqual:indexPath]) {
        type = NSFetchedResultsChangeUpdate;
    }
    
    switch (type) {
        case NSFetchedResultsChangeDelete:
            [_m_deletedIndexPaths addObject:indexPath];
            break;
        case NSFetchedResultsChangeInsert:
            [_m_deletedIndexPaths addObject:newIndexPath];
            break;
        case NSFetchedResultsChangeMove:
            [_m_fromIndexPaths addObject:indexPath];
            [_m_toIndexPaths addObject:newIndexPath];
            break;
        case NSFetchedResultsChangeUpdate:
            [_m_updatedIndexPaths addObject:indexPath];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSAssert(_flags.haveReceivedWillChange, @"Received a change without controllerWillChangeContent:");
    NSAssert(!_flags.haveReceivedDidChange, @"Received controllerDidChangeContent twice.");
    _flags.haveReceivedDidChange = YES;
    
    _insertedSections = [_m_insertedSections copy];
    _deletedSections = [_m_deletedSections copy];
    _insertedIndexPaths = [_m_insertedIndexPaths sortedArrayUsingSelector:@selector(compare:)];
    _deletedIndexPaths = [_m_deletedIndexPaths sortedArrayUsingSelector:@selector(ah_inverseCompare:)];
    _updatedIndexPaths = [_m_updatedIndexPaths copy];
    
    // Clear our mutable data (except moves!) since we don't need it anymore.
    _m_insertedSections = nil;
    _m_deletedSections = nil;
    _m_deletedIndexPaths = nil;
    _m_insertedIndexPaths = nil;
    _m_updatedIndexPaths = nil;
}

#pragma mark - Reporting Changes

/**
 Includes deletes and moves-from.
 */
- (NSIndexSet *)_indexesRemovedFromSection:(NSInteger)oldSection {
    NSMutableIndexSet *indexes = [NSMutableIndexSet new];
    for (NSIndexPath *moveFrom in _m_fromIndexPaths) {
        [indexes addIndex:[moveFrom indexAtPosition:1]];
    }
    for (NSIndexPath *indexPath in _deletedIndexPaths) {
        if ([indexPath indexAtPosition:0] == oldSection) {
            [indexes addIndex:[indexPath indexAtPosition:1]];
        }
    }
    return indexes;
}

/**
 Includes inserts and moves-to.
 */
- (NSIndexSet *)_indexesInsertedToSection:(NSInteger)newSection {
    NSMutableIndexSet *indexes = [NSMutableIndexSet new];
    for (NSIndexPath *moveTo in _m_toIndexPaths) {
        [indexes addIndex:[moveTo indexAtPosition:1]];
    }
    for (NSIndexPath *indexPath in _insertedIndexPaths) {
        if ([indexPath indexAtPosition:0] == newSection) {
            [indexes addIndex:[indexPath indexAtPosition:1]];
        }
    }
    return indexes;
}

- (NSInteger)oldSectionForNewSection:(NSInteger)newSection {
    if (!_flags.haveReceivedDidChange) { return NSNotFound; }
    
    if ([_insertedSections containsIndex:newSection]) { return NSNotFound; }
    
    NSInteger indexAfterDeletes = newSection - [_insertedSections countOfIndexesInRange:NSMakeRange(0, newSection)];
    return indexAfterDeletes + [_deletedSections countOfIndexesInRange:NSMakeRange(0, indexAfterDeletes)];
}

- (NSInteger)newSectionForOldSection:(NSInteger)oldSection {
    if (!_flags.haveReceivedDidChange) { return NSNotFound; }
    
    if ([_deletedSections containsIndex:oldSection]) { return NSNotFound; }
    
    NSInteger indexAfterDeletes = oldSection - [_deletedSections countOfIndexesInRange:NSMakeRange(0, oldSection)];
    return indexAfterDeletes + [_deletedSections countOfIndexesInRange:NSMakeRange(0, indexAfterDeletes)];
}

- (nullable NSIndexPath *)newIndexPathForOldIndexPath:(NSIndexPath *)oldIndexPath {
    if (!_flags.haveReceivedDidChange) { return nil; }
    
    // Was this item moved to here?
    NSInteger indexOfMove = [_m_fromIndexPaths indexOfObject:oldIndexPath];
    if (indexOfMove != NSNotFound) {
        return _m_toIndexPaths[indexOfMove];
    }
    
    // Is there a new section that corresponds to this one?
    NSInteger oldSection = [oldIndexPath indexAtPosition:0];
    NSInteger newSection = [self newSectionForOldSection:oldSection];
    if (newSection == NSNotFound) {
        return nil;
    }
    
    // Start with old, remove deletes/moves-out beneath, then add moves-in/inserts beneath
    NSInteger oldIndex = [oldIndexPath indexAtPosition:1];
    NSInteger indexAfterDeletes = oldIndex - [[self _indexesRemovedFromSection:oldSection] countOfIndexesInRange:NSMakeRange(0, oldIndex)];
    NSInteger newIndex = indexAfterDeletes + [[self _indexesInsertedToSection:newSection] countOfIndexesInRange:NSMakeRange(0, indexAfterDeletes)];
    NSUInteger indexArr[] = {newSection, newIndex};
    return [NSIndexPath indexPathWithIndexes:indexArr length:2];
}

- (nullable NSIndexPath *)oldIndexPathForNewIndexPath:(NSIndexPath *)newIndexPath {
    if (!_flags.haveReceivedDidChange) { return nil; }
    
    // Was this item moved to here?
    NSInteger indexOfMove = [_m_toIndexPaths indexOfObject:newIndexPath];
    if (indexOfMove != NSNotFound) {
        return _m_fromIndexPaths[indexOfMove];
    }
    
    // Is there a new section that corresponds to this one?
    NSInteger newSection = [newIndexPath indexAtPosition:0];
    NSInteger oldSection = [self oldSectionForNewSection:newSection];
    if (newSection == NSNotFound) {
        return nil;
    }
    
    // Start with old, remove moves-in/inserts beneath, then add deletes/moves-out beneath
    NSInteger newIndex = [newIndexPath indexAtPosition:1];
    NSInteger indexAfterDeletes = newIndex - [[self _indexesInsertedToSection:newSection] countOfIndexesInRange:NSMakeRange(0, newIndex)];
    NSInteger oldIndex = indexAfterDeletes + [[self _indexesRemovedFromSection:oldSection] countOfIndexesInRange:NSMakeRange(0, indexAfterDeletes)];
    NSUInteger indexArr[] = {oldSection, oldIndex};
    return [NSIndexPath indexPathWithIndexes:indexArr length:2];
}

- (void)enumerateMovesWithBlock:(void (^)(NSIndexPath * _Nonnull, NSIndexPath * _Nonnull, BOOL * _Nonnull))block {
    if (!_flags.haveReceivedDidChange) { return; }
    
    NSInteger count = _m_toIndexPaths.count;
    BOOL stop = NO;
    for (NSInteger i = 0; i < count; i++) {
        block(_m_fromIndexPaths[i], _m_toIndexPaths[i], &stop);
        if (stop) {
            return;
        }
    }
}

@end

NS_ASSUME_NONNULL_END
