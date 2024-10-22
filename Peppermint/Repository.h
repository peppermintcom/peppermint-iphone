//
//  RepositoryBase.h
//  Events
//
//  Created by James Hall on 8/19/10.
//  Copyright 2010 James Hall. All rights reserved.
//
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import "Entity.h"

@interface Repository : NSObject

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

//Begin transaction will return a repository instance that has a managed object context in the current thread. This implementation prevents concurrency problems.
+(Repository*) beginTransaction;

//Commit the changes in context to persistentStoreCoordinator
-(NSError*) endTransaction;

//Create request
- (NSManagedObject *) createEntity:(Class)entityClass;

//Delete request
- (void) deleteEntity:(NSManagedObject *)event;

//Fetch request
- (NSArray *) getResultsFromEntity:(Class)entityClass;
- (NSArray *) getResultsFromEntity:(Class)entityClass predicateOrNil:(NSPredicate *)predicateOrNil;
- (NSArray *) getResultsFromEntity:(Class)entityClass predicateOrNil:(NSPredicate *)predicateOrNil ascSortStringOrNil:(NSArray *)ascSortStringOrNil descSortStringOrNil:(NSArray *)descSortStringOrNil;
- (NSManagedObject *)objectWithURI:(NSURL *)uri;

//Batch update
-(NSBatchUpdateResult*) executeBatchUpdate:(Class)entityClass predicateOrNil:(NSPredicate *)predicateOrNil propertiesToConnect:(NSDictionary*)propertiesToConnect;

@end
