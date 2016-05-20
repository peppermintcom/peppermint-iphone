#import "google/datastore/v1beta3/Datastore.pbrpc.h"

#import <ProtoRPC/ProtoRPC.h>
#import <RxLibrary/GRXWriter+Immediate.h>

static NSString *const kPackageName = @"google.datastore.v1beta3";
static NSString *const kServiceName = @"Datastore";

@implementation Datastore

// Designated initializer
- (instancetype)initWithHost:(NSString *)host {
  return (self = [super initWithHost:host packageName:kPackageName serviceName:kServiceName]);
}

// Override superclass initializer to disallow different package and service names.
- (instancetype)initWithHost:(NSString *)host
                 packageName:(NSString *)packageName
                 serviceName:(NSString *)serviceName {
  return [self initWithHost:host];
}

+ (instancetype)serviceWithHost:(NSString *)host {
  return [[self alloc] initWithHost:host];
}


#pragma mark Lookup(LookupRequest) returns (LookupResponse)

- (void)lookupWithRequest:(LookupRequest *)request handler:(void(^)(LookupResponse *response, NSError *error))handler{
  [[self RPCToLookupWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToLookupWithRequest:(LookupRequest *)request handler:(void(^)(LookupResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"Lookup"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LookupResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark RunQuery(RunQueryRequest) returns (RunQueryResponse)

- (void)runQueryWithRequest:(RunQueryRequest *)request handler:(void(^)(RunQueryResponse *response, NSError *error))handler{
  [[self RPCToRunQueryWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToRunQueryWithRequest:(RunQueryRequest *)request handler:(void(^)(RunQueryResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"RunQuery"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[RunQueryResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark BeginTransaction(BeginTransactionRequest) returns (BeginTransactionResponse)

- (void)beginTransactionWithRequest:(BeginTransactionRequest *)request handler:(void(^)(BeginTransactionResponse *response, NSError *error))handler{
  [[self RPCToBeginTransactionWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToBeginTransactionWithRequest:(BeginTransactionRequest *)request handler:(void(^)(BeginTransactionResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"BeginTransaction"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[BeginTransactionResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark Commit(CommitRequest) returns (CommitResponse)

- (void)commitWithRequest:(CommitRequest *)request handler:(void(^)(CommitResponse *response, NSError *error))handler{
  [[self RPCToCommitWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToCommitWithRequest:(CommitRequest *)request handler:(void(^)(CommitResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"Commit"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[CommitResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark Rollback(RollbackRequest) returns (RollbackResponse)

- (void)rollbackWithRequest:(RollbackRequest *)request handler:(void(^)(RollbackResponse *response, NSError *error))handler{
  [[self RPCToRollbackWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToRollbackWithRequest:(RollbackRequest *)request handler:(void(^)(RollbackResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"Rollback"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[RollbackResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark AllocateIds(AllocateIdsRequest) returns (AllocateIdsResponse)

- (void)allocateIdsWithRequest:(AllocateIdsRequest *)request handler:(void(^)(AllocateIdsResponse *response, NSError *error))handler{
  [[self RPCToAllocateIdsWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToAllocateIdsWithRequest:(AllocateIdsRequest *)request handler:(void(^)(AllocateIdsResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"AllocateIds"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[AllocateIdsResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
@end
