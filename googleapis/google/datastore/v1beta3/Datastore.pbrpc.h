#import "google/datastore/v1beta3/Datastore.pbobjc.h"

#import <ProtoRPC/ProtoService.h>
#import <RxLibrary/GRXWriteable.h>
#import <RxLibrary/GRXWriter.h>

#import "google/api/Annotations.pbobjc.h"
#import "google/datastore/v1beta3/Entity.pbobjc.h"
#import "google/datastore/v1beta3/Query.pbobjc.h"

@protocol Datastore <NSObject>

#pragma mark Lookup(LookupRequest) returns (LookupResponse)

- (void)lookupWithRequest:(LookupRequest *)request handler:(void(^)(LookupResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToLookupWithRequest:(LookupRequest *)request handler:(void(^)(LookupResponse *response, NSError *error))handler;


#pragma mark RunQuery(RunQueryRequest) returns (RunQueryResponse)

- (void)runQueryWithRequest:(RunQueryRequest *)request handler:(void(^)(RunQueryResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToRunQueryWithRequest:(RunQueryRequest *)request handler:(void(^)(RunQueryResponse *response, NSError *error))handler;


#pragma mark BeginTransaction(BeginTransactionRequest) returns (BeginTransactionResponse)

- (void)beginTransactionWithRequest:(BeginTransactionRequest *)request handler:(void(^)(BeginTransactionResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToBeginTransactionWithRequest:(BeginTransactionRequest *)request handler:(void(^)(BeginTransactionResponse *response, NSError *error))handler;


#pragma mark Commit(CommitRequest) returns (CommitResponse)

- (void)commitWithRequest:(CommitRequest *)request handler:(void(^)(CommitResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToCommitWithRequest:(CommitRequest *)request handler:(void(^)(CommitResponse *response, NSError *error))handler;


#pragma mark Rollback(RollbackRequest) returns (RollbackResponse)

- (void)rollbackWithRequest:(RollbackRequest *)request handler:(void(^)(RollbackResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToRollbackWithRequest:(RollbackRequest *)request handler:(void(^)(RollbackResponse *response, NSError *error))handler;


#pragma mark AllocateIds(AllocateIdsRequest) returns (AllocateIdsResponse)

- (void)allocateIdsWithRequest:(AllocateIdsRequest *)request handler:(void(^)(AllocateIdsResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToAllocateIdsWithRequest:(AllocateIdsRequest *)request handler:(void(^)(AllocateIdsResponse *response, NSError *error))handler;


@end

// Basic service implementation, over gRPC, that only does marshalling and parsing.
@interface Datastore : ProtoService<Datastore>
- (instancetype)initWithHost:(NSString *)host NS_DESIGNATED_INITIALIZER;
+ (instancetype)serviceWithHost:(NSString *)host;
@end
