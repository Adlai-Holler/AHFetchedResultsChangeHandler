//
//  AHFetchedResultsChangeSet.h
//  FetchedResultsController
//
//  Created by Adlai Holler on 10/27/15.
//  Copyright © 2015 Adlai Holler. All rights reserved.
//

@import Foundation;
@import CoreData;

NS_ASSUME_NONNULL_BEGIN

/**
 A set of changes as reported by NSFetchedResultsController.
 
 All indexes associated with deletes or reloads are from _before_ the update.
 All indexes associated with insertions are from _after_ the update.
 
 See https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TableView_iPhone/ManageInsertDeleteRow/ManageInsertDeleteRow.html#//apple_ref/doc/uid/TP40007451-CH10-SW17 for an explanation of how hierarchy changes are reported.
 */
@interface AHFetchedResultsChangeSet : NSObject


/**
 Returns the index after the update for the section at the given index before the update.
 
 If the section was inserted, returns NSNotFound.
 */
- (NSInteger)newSectionForOldSection:(NSInteger)oldSection;

/**
 Returns the index before the update for the section at the given index after the update.
 
 If the section was deleted, returns NSNotFound.
 */
- (NSInteger)oldSectionForNewSection:(NSInteger)newSection;

/**
 Returns the index path after the update for the object at the given index before the update.
 
 If the object was deleted, returns nil.
 */
- (nullable NSIndexPath *)newIndexPathForOldIndexPath:(NSIndexPath *)oldIndexPath;

/**
 Returns the index path before the update for the object at the given index after the update.
 
 If the object was inserted, returns nil.
 */
- (nullable NSIndexPath *)oldIndexPathForNewIndexPath:(NSIndexPath *)newIndexPath;

/**
 The indexes of the sections deleted during this change. These indexes are from before the update.
 */
@property (nonatomic, readonly) NSIndexSet *deletedSections;

/**
 The indexes of the sections inserted during this change. These indexes are from after the update.
 */
@property (nonatomic, readonly) NSIndexSet *insertedSections;

/**
 The index paths of the objects updated during this change.
 
 These index paths are from before the update and are reported in arbitrary order.
 */
@property (nonatomic, readonly) NSArray<NSIndexPath *> *updatedIndexPaths;

/**
 The index paths of the objects deleted during this change.
 
 These index paths are from before the update and are reported in descending order.
 */
@property (nonatomic, readonly) NSArray<NSIndexPath *> *deletedIndexPaths;

/**
 The index paths of the objects inserted during this change.
 
 These index paths are from after the update and are reported in ascending order.
 
 NOTE: Items contained in newly-inserted sections will be included in this array.
 If batched together with the section insert, `UITableView` and `UICollectionView`
 will crash if you report those item inserts too.
 */
@property (nonatomic, readonly) NSArray<NSIndexPath *> *insertedIndexPaths;

/**
 Enumerate all the object moves in the change using the given block in arbitrary order.
 
 - `indexPath` is from before the update.
 - `newIndexPath` is from after the update.
 - Set `stop` to YES to end enumeration.
 */
- (void)enumerateMovesWithBlock:(void (^)(NSIndexPath *indexPath, NSIndexPath *newIndexPath, BOOL *stop))block;

@end

NS_ASSUME_NONNULL_END
