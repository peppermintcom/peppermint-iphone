#import "google/devtools/cloudtrace/v1/Trace.pbrpc.h"

#import <ProtoRPC/ProtoRPC.h>
#import <RxLibrary/GRXWriter+Immediate.h>

static NSString *const kPackageName = @"google.devtools.cloudtrace.v1";
static NSString *const kServiceName = @"TraceService";

@implementation TraceService

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


#pragma mark ListTraces(ListTracesRequest) returns (ListTracesResponse)

- (void)listTracesWithRequest:(ListTracesRequest *)request handler:(void(^)(ListTracesResponse *response, NSError *error))handler{
  [[self RPCToListTracesWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToListTracesWithRequest:(ListTracesRequest *)request handler:(void(^)(ListTracesResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"ListTraces"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[ListTracesResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark GetTrace(GetTraceRequest) returns (Trace)

- (void)getTraceWithRequest:(GetTraceRequest *)request handler:(void(^)(Trace *response, NSError *error))handler{
  [[self RPCToGetTraceWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToGetTraceWithRequest:(GetTraceRequest *)request handler:(void(^)(Trace *response, NSError *error))handler{
  return [self RPCToMethod:@"GetTrace"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Trace class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark PatchTraces(PatchTracesRequest) returns (Empty)

- (void)patchTracesWithRequest:(PatchTracesRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler{
  [[self RPCToPatchTracesWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToPatchTracesWithRequest:(PatchTracesRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler{
  return [self RPCToMethod:@"PatchTraces"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[GPBEmpty class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
@end
