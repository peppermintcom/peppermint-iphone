#import "google/logging/v2/LoggingMetrics.pbobjc.h"

#import <ProtoRPC/ProtoService.h>
#import <RxLibrary/GRXWriteable.h>
#import <RxLibrary/GRXWriter.h>

#import "google/api/Annotations.pbobjc.h"
#import "google/protobuf/Empty.pbobjc.h"

@protocol MetricsServiceV2 <NSObject>

#pragma mark ListLogMetrics(ListLogMetricsRequest) returns (ListLogMetricsResponse)

- (void)listLogMetricsWithRequest:(ListLogMetricsRequest *)request handler:(void(^)(ListLogMetricsResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToListLogMetricsWithRequest:(ListLogMetricsRequest *)request handler:(void(^)(ListLogMetricsResponse *response, NSError *error))handler;


#pragma mark GetLogMetric(GetLogMetricRequest) returns (LogMetric)

- (void)getLogMetricWithRequest:(GetLogMetricRequest *)request handler:(void(^)(LogMetric *response, NSError *error))handler;

- (ProtoRPC *)RPCToGetLogMetricWithRequest:(GetLogMetricRequest *)request handler:(void(^)(LogMetric *response, NSError *error))handler;


#pragma mark CreateLogMetric(CreateLogMetricRequest) returns (LogMetric)

- (void)createLogMetricWithRequest:(CreateLogMetricRequest *)request handler:(void(^)(LogMetric *response, NSError *error))handler;

- (ProtoRPC *)RPCToCreateLogMetricWithRequest:(CreateLogMetricRequest *)request handler:(void(^)(LogMetric *response, NSError *error))handler;


#pragma mark UpdateLogMetric(UpdateLogMetricRequest) returns (LogMetric)

- (void)updateLogMetricWithRequest:(UpdateLogMetricRequest *)request handler:(void(^)(LogMetric *response, NSError *error))handler;

- (ProtoRPC *)RPCToUpdateLogMetricWithRequest:(UpdateLogMetricRequest *)request handler:(void(^)(LogMetric *response, NSError *error))handler;


#pragma mark DeleteLogMetric(DeleteLogMetricRequest) returns (Empty)

- (void)deleteLogMetricWithRequest:(DeleteLogMetricRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler;

- (ProtoRPC *)RPCToDeleteLogMetricWithRequest:(DeleteLogMetricRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler;


@end

// Basic service implementation, over gRPC, that only does marshalling and parsing.
@interface MetricsServiceV2 : ProtoService<MetricsServiceV2>
- (instancetype)initWithHost:(NSString *)host NS_DESIGNATED_INITIALIZER;
+ (instancetype)serviceWithHost:(NSString *)host;
@end
