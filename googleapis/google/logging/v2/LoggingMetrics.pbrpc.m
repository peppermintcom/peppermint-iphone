#import "google/logging/v2/LoggingMetrics.pbrpc.h"

#import <ProtoRPC/ProtoRPC.h>
#import <RxLibrary/GRXWriter+Immediate.h>

static NSString *const kPackageName = @"google.logging.v2";
static NSString *const kServiceName = @"MetricsServiceV2";

@implementation MetricsServiceV2

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


#pragma mark ListLogMetrics(ListLogMetricsRequest) returns (ListLogMetricsResponse)

- (void)listLogMetricsWithRequest:(ListLogMetricsRequest *)request handler:(void(^)(ListLogMetricsResponse *response, NSError *error))handler{
  [[self RPCToListLogMetricsWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToListLogMetricsWithRequest:(ListLogMetricsRequest *)request handler:(void(^)(ListLogMetricsResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"ListLogMetrics"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[ListLogMetricsResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark GetLogMetric(GetLogMetricRequest) returns (LogMetric)

- (void)getLogMetricWithRequest:(GetLogMetricRequest *)request handler:(void(^)(LogMetric *response, NSError *error))handler{
  [[self RPCToGetLogMetricWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToGetLogMetricWithRequest:(GetLogMetricRequest *)request handler:(void(^)(LogMetric *response, NSError *error))handler{
  return [self RPCToMethod:@"GetLogMetric"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LogMetric class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark CreateLogMetric(CreateLogMetricRequest) returns (LogMetric)

- (void)createLogMetricWithRequest:(CreateLogMetricRequest *)request handler:(void(^)(LogMetric *response, NSError *error))handler{
  [[self RPCToCreateLogMetricWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToCreateLogMetricWithRequest:(CreateLogMetricRequest *)request handler:(void(^)(LogMetric *response, NSError *error))handler{
  return [self RPCToMethod:@"CreateLogMetric"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LogMetric class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark UpdateLogMetric(UpdateLogMetricRequest) returns (LogMetric)

- (void)updateLogMetricWithRequest:(UpdateLogMetricRequest *)request handler:(void(^)(LogMetric *response, NSError *error))handler{
  [[self RPCToUpdateLogMetricWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToUpdateLogMetricWithRequest:(UpdateLogMetricRequest *)request handler:(void(^)(LogMetric *response, NSError *error))handler{
  return [self RPCToMethod:@"UpdateLogMetric"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LogMetric class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark DeleteLogMetric(DeleteLogMetricRequest) returns (Empty)

- (void)deleteLogMetricWithRequest:(DeleteLogMetricRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler{
  [[self RPCToDeleteLogMetricWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToDeleteLogMetricWithRequest:(DeleteLogMetricRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler{
  return [self RPCToMethod:@"DeleteLogMetric"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[GPBEmpty class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
@end
