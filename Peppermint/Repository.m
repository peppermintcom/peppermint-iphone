//
//  Repository.m
//  Events
//
//  Created by James Hall on 8/19/10.
//  Copyright 2010 James Hall. All rights reserved.
//

#import "Repository.h"

#if !(TARGET_OS_WATCH)
#import "AppDelegate.h"
#else
#import "ExtensionDelegate.h"
#endif


@implementation Repository

@synthesize managedObjectContext = _managedObjectContext;

#pragma mark - Access
+(Repository*) beginTransaction; {
#if !(TARGET_OS_WATCH)
  NSPersistentStoreCoordinator *persistentStoreCoordinator = [[AppDelegate Instance] persistentStoreCoordinator];
#else
  NSPersistentStoreCoordinator *persistentStoreCoordinator = [[ExtensionDelegate Instance] persistentStoreCoordinator];
#endif
    Repository *repository = [[Repository alloc] init];
    repository.managedObjectContext =
    [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [repository.managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    [repository.managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    return repository;
}

-(NSError*) endTransaction
{
    NSError *error = nil;
    if(!self.managedObjectContext) {
        error = [NSError errorWithDomain:@"Current context is nil. Please create repository entity with [Repository beginTransaction] command." code:0 userInfo:nil];
    } else if(self.managedObjectContext.persistentStoreCoordinator.persistentStores.count == 0) {
        error = [NSError errorWithDomain:@"Can not end Trasaction, because the database file is removed." code:-1 userInfo:nil];
    } else if ([self.managedObjectContext hasChanges]) {
        [self.managedObjectContext save:&error];
    }
    
    if(error) {
        NSLog(@"Error during endTransaction. %@", error);
    }
    
    return error;
}

#pragma mark - Create
-(NSManagedObject *) createEntity:(Class)entityClass
{
    NSString *entityName = NSStringFromClass(entityClass);
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    return (NSManagedObject *)newManagedObject;
}

#pragma mark - Delete
-(void)deleteEntity:(NSManagedObject *)event
{
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:event];
}

#pragma mark - Fetch

- (NSArray *) getResultsFromEntity:(Class)entityClass
{
	return [self getResultsFromEntity:entityClass predicateOrNil:nil];
}

- (NSArray *) getResultsFromEntity:(Class)entityClass predicateOrNil:(NSPredicate *)predicateOrNil;
{
	return [self getResultsFromEntity:entityClass predicateOrNil:predicateOrNil ascSortStringOrNil:nil descSortStringOrNil:nil];
}

- (NSArray *) getResultsFromEntity:(Class)entityClass predicateOrNil:(NSPredicate *)predicateOrNil ascSortStringOrNil:(NSArray *)ascSortStringOrNil descSortStringOrNil:(NSArray *)descSortStringOrNil
{
    NSString *entityName = NSStringFromClass(entityClass);
	NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
											  inManagedObjectContext:[self managedObjectContext]]; 
	[request setEntity:entity]; 
	
	if(predicateOrNil != nil)
	{
		[request setPredicate:predicateOrNil];
	}
	
	NSMutableArray *sortDescriptors = [[NSMutableArray alloc]init];
	
	if(ascSortStringOrNil != nil)
	{
		for (NSString *asc in ascSortStringOrNil)
		{
			NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:asc ascending:YES];
			[sortDescriptors addObject:sortDescriptor];
		}
    }
	if(descSortStringOrNil != nil)
	{
		for (NSString *desc in descSortStringOrNil)
		{
			NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:desc ascending:NO];
			[sortDescriptors addObject:sortDescriptor];
		}
    }
    [request setSortDescriptors:sortDescriptors];
    
	NSError *error;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];    
    if(error) {
        NSLog(@"An error occured during DB operation. Err: %@", error);
    }    
	return results;    
}

- (NSManagedObject *)objectWithURI:(NSURL *)uri
{
    NSManagedObjectID *objectID =
    [self.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
    
    if (!objectID) {
        return nil;
    }
    
    NSManagedObject *objectForID = [self.managedObjectContext objectWithID:objectID];
    if (![objectForID isFault]) {
        return objectForID;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[objectID entity]];
    
    // Equivalent to
    // predicate = [NSPredicate predicateWithFormat:@"SELF = %@", objectForID];
    NSPredicate *predicate =
    [NSComparisonPredicate
     predicateWithLeftExpression:
     [NSExpression expressionForEvaluatedObject]
     rightExpression:
     [NSExpression expressionForConstantValue:objectForID]
     modifier:NSDirectPredicateModifier
     type:NSEqualToPredicateOperatorType
     options:0];
    [request setPredicate:predicate];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:nil];
    if ([results count] > 0 )
    {
        return [results objectAtIndex:0];
    }
    return nil;
}

-(NSInteger) executeBatchUpdate:(Class)entityClass predicateOrNil:(NSPredicate *)predicateOrNil propertiesToConnect:(NSDictionary*)propertiesToConnect {
    NSNumber *numberOfUpdatedEntities = @0;
    NSString *entityName = NSStringFromClass(entityClass);
    NSBatchUpdateRequest *batchRequest = [[NSBatchUpdateRequest alloc] initWithEntityName:entityName];
    batchRequest.predicate = predicateOrNil;
    batchRequest.propertiesToUpdate = propertiesToConnect;
    batchRequest.resultType = NSUpdatedObjectsCountResultType;
    
    NSError *error;
    NSBatchUpdateResult *batchUpdateResult = (NSBatchUpdateResult *)[self.managedObjectContext executeRequest:batchRequest error:&error];
    
    if(error) {
        NSLog(@"error is:%@", error.localizedDescription);
    } else {
        numberOfUpdatedEntities = batchUpdateResult.result;
    }
    return numberOfUpdatedEntities.integerValue;
}

@end
