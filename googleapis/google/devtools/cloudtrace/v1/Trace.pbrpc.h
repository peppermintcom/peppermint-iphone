#import "google/devtools/cloudtrace/v1/Trace.pbobjc.h"

#import <ProtoRPC/ProtoService.h>
#import <RxLibrary/GRXWriteable.h>
#import <RxLibrary/GRXWriter.h>

#import "google/api/Annotations.pbobjc.h"
#import "google/protobuf/Empty.pbobjc.h"
#import "google/protobuf/Timestamp.pbobjc.h"

@protocol TraceService <NSObject>

#pragma mark ListTraces(ListTracesRequest) returns (ListTracesResponse)

- (void)listTracesWithRequest:(ListTracesRequest *)request handler:(void(^)(ListTracesResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToListTracesWithRequest:(ListTracesRequest *)request handler:(void(^)(ListTracesResponse *response, NSError *error))handler;


#pragma mark GetTrace(GetTraceRequest) returns (Trace)

- (void)getTraceWithRequest:(GetTraceRequest *)request handler:(void(^)(Trace *response, NSError *error))handler;

- (ProtoRPC *)RPCToGetTraceWithRequest:(GetTraceRequest *)request handler:(void(^)(Trace *response, NSError *error))handler;


#pragma mark PatchTraces(PatchTracesRequest) returns (Empty)

- (void)patchTracesWithRequest:(PatchTracesRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler;

- (ProtoRPC *)RPCToPatchTracesWithRequest:(PatchTracesRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler;


@end

// Basic service implementation, over gRPC, that only does marshalling and parsing.
@interface TraceService : ProtoService<TraceService>
- (instancetype)initWithHost:(NSString *)host NS_DESIGNATED_INITIALIZER;
+ (instancetype)serviceWithHost:(NSString *)host;
@end
