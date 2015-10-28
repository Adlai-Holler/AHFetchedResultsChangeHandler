//
//  AHFetchedResultsKitTests.m
//  AHFetchedResultsKitTests
//
//  Created by Adlai Holler on 10/27/15.
//  Copyright © 2015 Adlai Holler. All rights reserved.
//

@import XCTest;
@import CoreData;
@import AHFetchedResultsKit;
#import "AHFetchedResultsKitTestModel.h"


@interface AHFetchedResultsKitTests : XCTestCase
@property (nonatomic, strong) AHFetchedResultsKitTestModel *model;
@property (nonatomic, strong) NSFetchedResultsController *frc;
@property (nonatomic, strong) AHFetchedResultsChangeHandler *handler;
@end

@implementation AHFetchedResultsKitTests

- (void)setUp {
    [super setUp];
    self.model = [AHFetchedResultsKitTestModel new];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Employee"];
    fetchRequest.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"department.name" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES] ];
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.model.context sectionNameKeyPath:@"department" cacheName:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatTheForwardingDelegateReceivesCalls {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testThatTheNSNotificationIsSentProperly {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testThatTheDidChangeBlockIsCalledProperly {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

@end
