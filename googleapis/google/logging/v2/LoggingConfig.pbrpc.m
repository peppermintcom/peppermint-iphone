#import "google/logging/v2/LoggingConfig.pbrpc.h"

#import <ProtoRPC/ProtoRPC.h>
#import <RxLibrary/GRXWriter+Immediate.h>

static NSString *const kPackageName = @"google.logging.v2";
static NSString *const kServiceName = @"ConfigServiceV2";

@implementation ConfigServiceV2

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


#pragma mark ListSinks(ListSinksRequest) returns (ListSinksResponse)

- (void)listSinksWithRequest:(ListSinksRequest *)request handler:(void(^)(ListSinksResponse *response, NSError *error))handler{
  [[self RPCToListSinksWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToListSinksWithRequest:(ListSinksRequest *)request handler:(void(^)(ListSinksResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"ListSinks"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[ListSinksResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark GetSink(GetSinkRequest) returns (LogSink)

- (void)getSinkWithRequest:(GetSinkRequest *)request handler:(void(^)(LogSink *response, NSError *error))handler{
  [[self RPCToGetSinkWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToGetSinkWithRequest:(GetSinkRequest *)request handler:(void(^)(LogSink *response, NSError *error))handler{
  return [self RPCToMethod:@"GetSink"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LogSink class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark CreateSink(CreateSinkRequest) returns (LogSink)

- (void)createSinkWithRequest:(CreateSinkRequest *)request handler:(void(^)(LogSink *response, NSError *error))handler{
  [[self RPCToCreateSinkWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToCreateSinkWithRequest:(CreateSinkRequest *)request handler:(void(^)(LogSink *response, NSError *error))handler{
  return [self RPCToMethod:@"CreateSink"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LogSink class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark UpdateSink(UpdateSinkRequest) returns (LogSink)

- (void)updateSinkWithRequest:(UpdateSinkRequest *)request handler:(void(^)(LogSink *response, NSError *error))handler{
  [[self RPCToUpdateSinkWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToUpdateSinkWithRequest:(UpdateSinkRequest *)request handler:(void(^)(LogSink *response, NSError *error))handler{
  return [self RPCToMethod:@"UpdateSink"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LogSink class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark DeleteSink(DeleteSinkRequest) returns (Empty)

- (void)deleteSinkWithRequest:(DeleteSinkRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler{
  [[self RPCToDeleteSinkWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToDeleteSinkWithRequest:(DeleteSinkRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler{
  return [self RPCToMethod:@"DeleteSink"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[GPBEmpty class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
@end
