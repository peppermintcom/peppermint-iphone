#import "google/logging/v2/Logging.pbrpc.h"

#import <ProtoRPC/ProtoRPC.h>
#import <RxLibrary/GRXWriter+Immediate.h>

static NSString *const kPackageName = @"google.logging.v2";
static NSString *const kServiceName = @"LoggingServiceV2";

@implementation LoggingServiceV2

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


#pragma mark DeleteLog(DeleteLogRequest) returns (Empty)

- (void)deleteLogWithRequest:(DeleteLogRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler{
  [[self RPCToDeleteLogWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToDeleteLogWithRequest:(DeleteLogRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler{
  return [self RPCToMethod:@"DeleteLog"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[GPBEmpty class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark WriteLogEntries(WriteLogEntriesRequest) returns (WriteLogEntriesResponse)

- (void)writeLogEntriesWithRequest:(WriteLogEntriesRequest *)request handler:(void(^)(WriteLogEntriesResponse *response, NSError *error))handler{
  [[self RPCToWriteLogEntriesWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToWriteLogEntriesWithRequest:(WriteLogEntriesRequest *)request handler:(void(^)(WriteLogEntriesResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"WriteLogEntries"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[WriteLogEntriesResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark ListLogEntries(ListLogEntriesRequest) returns (ListLogEntriesResponse)

- (void)listLogEntriesWithRequest:(ListLogEntriesRequest *)request handler:(void(^)(ListLogEntriesResponse *response, NSError *error))handler{
  [[self RPCToListLogEntriesWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToListLogEntriesWithRequest:(ListLogEntriesRequest *)request handler:(void(^)(ListLogEntriesResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"ListLogEntries"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[ListLogEntriesResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark ListMonitoredResourceDescriptors(ListMonitoredResourceDescriptorsRequest) returns (ListMonitoredResourceDescriptorsResponse)

- (void)listMonitoredResourceDescriptorsWithRequest:(ListMonitoredResourceDescriptorsRequest *)request handler:(void(^)(ListMonitoredResourceDescriptorsResponse *response, NSError *error))handler{
  [[self RPCToListMonitoredResourceDescriptorsWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToListMonitoredResourceDescriptorsWithRequest:(ListMonitoredResourceDescriptorsRequest *)request handler:(void(^)(ListMonitoredResourceDescriptorsResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"ListMonitoredResourceDescriptors"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[ListMonitoredResourceDescriptorsResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
@end
