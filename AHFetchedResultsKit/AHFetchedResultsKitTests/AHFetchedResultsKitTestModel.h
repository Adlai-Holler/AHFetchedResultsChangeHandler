//
//  AHFetchedResultsKitTestModel.h
//  AHFetchedResultsKit
//
//  Created by Adlai Holler on 10/27/15.
//  Copyright © 2015 Adlai Holler. All rights reserved.
//

@import CoreData;

@class AHEmployee, AHDepartment;

@interface AHFetchedResultsKitTestModel: NSObject
@property (nonatomic, strong, readonly) NSManagedObjectContext *context;
@end

@interface AHDepartment: NSManagedObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSSet<AHEmployee *> *employees;
@end

@interface AHEmployee: NSManagedObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) AHDepartment *department;
@end
