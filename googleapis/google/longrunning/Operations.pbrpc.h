#import "google/longrunning/Operations.pbobjc.h"

#import <ProtoRPC/ProtoService.h>
#import <RxLibrary/GRXWriteable.h>
#import <RxLibrary/GRXWriter.h>

#import "google/api/Annotations.pbobjc.h"
#import "google/protobuf/Any.pbobjc.h"
#import "google/protobuf/Empty.pbobjc.h"
#import "google/rpc/Status.pbobjc.h"

@protocol Operations <NSObject>

#pragma mark GetOperation(GetOperationRequest) returns (Operation)

- (void)getOperationWithRequest:(GetOperationRequest *)request handler:(void(^)(Operation *response, NSError *error))handler;

- (ProtoRPC *)RPCToGetOperationWithRequest:(GetOperationRequest *)request handler:(void(^)(Operation *response, NSError *error))handler;


#pragma mark ListOperations(ListOperationsRequest) returns (ListOperationsResponse)

- (void)listOperationsWithRequest:(ListOperationsRequest *)request handler:(void(^)(ListOperationsResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToListOperationsWithRequest:(ListOperationsRequest *)request handler:(void(^)(ListOperationsResponse *response, NSError *error))handler;


#pragma mark CancelOperation(CancelOperationRequest) returns (Empty)

- (void)cancelOperationWithRequest:(CancelOperationRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler;

- (ProtoRPC *)RPCToCancelOperationWithRequest:(CancelOperationRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler;


#pragma mark DeleteOperation(DeleteOperationRequest) returns (Empty)

- (void)deleteOperationWithRequest:(DeleteOperationRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler;

- (ProtoRPC *)RPCToDeleteOperationWithRequest:(DeleteOperationRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler;


@end

// Basic service implementation, over gRPC, that only does marshalling and parsing.
@interface Operations : ProtoService<Operations>
- (instancetype)initWithHost:(NSString *)host NS_DESIGNATED_INITIALIZER;
+ (instancetype)serviceWithHost:(NSString *)host;
@end
