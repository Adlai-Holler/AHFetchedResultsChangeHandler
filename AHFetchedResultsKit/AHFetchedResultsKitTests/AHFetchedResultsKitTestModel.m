//
//  AHFetchedResultsKitTestModel.m
//  AHFetchedResultsKit
//
//  Created by Adlai Holler on 10/27/15.
//  Copyright © 2015 Adlai Holler. All rights reserved.
//

#import "AHFetchedResultsKitTestModel.h"

@interface AHFetchedResultsKitTestModel ()
@property (nonatomic, strong) NSPersistentStoreCoordinator *psc;
@end

@implementation AHFetchedResultsKitTestModel

- (instancetype)init {
    self = [super init];
    if (!self) { return nil; }
    _psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:@[[NSBundle bundleForClass:self.class]]]];
    [_psc addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:nil];
    _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _context.persistentStoreCoordinator = _psc;
    
    return self;
}

@end

@implementation AHDepartment

@dynamic name;
@dynamic employees;

@end

@implementation AHEmployee

@dynamic name;
@dynamic department;

@end
