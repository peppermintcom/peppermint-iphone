// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: google/logging/v2/logging_metrics.proto

#import "GPBProtocolBuffers.h"

#if GOOGLE_PROTOBUF_OBJC_GEN_VERSION != 30000
#error This file was generated by a different version of protoc which is incompatible with your Protocol Buffer library sources.
#endif

// @@protoc_insertion_point(imports)

CF_EXTERN_C_BEGIN

@class LogMetric;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - LoggingMetricsRoot

@interface LoggingMetricsRoot : GPBRootObject

// The base class provides:
//   + (GPBExtensionRegistry *)extensionRegistry;
// which is an GPBExtensionRegistry that includes all the extensions defined by
// this file and all files that it depends on.

@end

#pragma mark - LogMetric

typedef GPB_ENUM(LogMetric_FieldNumber) {
  LogMetric_FieldNumber_Name = 1,
  LogMetric_FieldNumber_Description_p = 2,
  LogMetric_FieldNumber_Filter = 3,
};

// Describes a logs-based metric.  The value of the metric is the
// number of log entries that match a logs filter.
@interface LogMetric : GPBMessage

// Required. The client-assigned metric identifier. Example:
// `"severe_errors"`.  Metric identifiers are limited to 1000
// characters and can include only the following characters: `A-Z`,
// `a-z`, `0-9`, and the special characters `_-.,+!*',()%/\`.  The
// forward-slash character (`/`) denotes a hierarchy of name pieces,
// and it cannot be the first character of the name.
@property(nonatomic, readwrite, copy, null_resettable) NSString *name;

// A description of this metric, which is used in documentation.
@property(nonatomic, readwrite, copy, null_resettable) NSString *description_p;

// An [advanced logs filter](/logging/docs/view/advanced_filters).
// Example: `"logName:syslog AND severity>=ERROR"`.
@property(nonatomic, readwrite, copy, null_resettable) NSString *filter;

@end

#pragma mark - ListLogMetricsRequest

typedef GPB_ENUM(ListLogMetricsRequest_FieldNumber) {
  ListLogMetricsRequest_FieldNumber_ProjectName = 1,
  ListLogMetricsRequest_FieldNumber_PageToken = 2,
  ListLogMetricsRequest_FieldNumber_PageSize = 3,
};

// The parameters to ListLogMetrics.
@interface ListLogMetricsRequest : GPBMessage

// Required. The resource name of the project containing the metrics.
// Example: `"projects/my-project-id"`.
@property(nonatomic, readwrite, copy, null_resettable) NSString *projectName;

// Optional. If the `pageToken` request parameter is supplied, then the next
// page of results in the set are retrieved.  The `pageToken` parameter must
// be set with the value of the `nextPageToken` result parameter from the
// previous request.  The value of `projectName` must
// be the same as in the previous request.
@property(nonatomic, readwrite, copy, null_resettable) NSString *pageToken;

// Optional. The maximum number of results to return from this request.  Fewer
// results might be returned. You must check for the `nextPageToken` result to
// determine if additional results are available, which you can retrieve by
// passing the `nextPageToken` value in the `pageToken` parameter to the next
// request.
@property(nonatomic, readwrite) int32_t pageSize;

@end

#pragma mark - ListLogMetricsResponse

typedef GPB_ENUM(ListLogMetricsResponse_FieldNumber) {
  ListLogMetricsResponse_FieldNumber_MetricsArray = 1,
  ListLogMetricsResponse_FieldNumber_NextPageToken = 2,
};

// Result returned from ListLogMetrics.
@interface ListLogMetricsResponse : GPBMessage

// A list of logs-based metrics.
// |metricsArray| contains |LogMetric|
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray *metricsArray;
@property(nonatomic, readonly) NSUInteger metricsArray_Count;

// If there are more results than were returned, then `nextPageToken` is given
// a value in the response.  To get the next batch of results, call this
// method again using the value of `nextPageToken` as `pageToken`.
@property(nonatomic, readwrite, copy, null_resettable) NSString *nextPageToken;

@end

#pragma mark - GetLogMetricRequest

typedef GPB_ENUM(GetLogMetricRequest_FieldNumber) {
  GetLogMetricRequest_FieldNumber_MetricName = 1,
};

// The parameters to GetLogMetric.
@interface GetLogMetricRequest : GPBMessage

// The resource name of the desired metric.
// Example: `"projects/my-project-id/metrics/my-metric-id"`.
@property(nonatomic, readwrite, copy, null_resettable) NSString *metricName;

@end

#pragma mark - CreateLogMetricRequest

typedef GPB_ENUM(CreateLogMetricRequest_FieldNumber) {
  CreateLogMetricRequest_FieldNumber_ProjectName = 1,
  CreateLogMetricRequest_FieldNumber_Metric = 2,
};

// The parameters to CreateLogMetric.
@interface CreateLogMetricRequest : GPBMessage

// The resource name of the project in which to create the metric.
// Example: `"projects/my-project-id"`.
//
// The new metric must be provided in the request.
@property(nonatomic, readwrite, copy, null_resettable) NSString *projectName;

// The new logs-based metric, which must not have an identifier that
// already exists.
@property(nonatomic, readwrite) BOOL hasMetric;
@property(nonatomic, readwrite, strong, null_resettable) LogMetric *metric;

@end

#pragma mark - UpdateLogMetricRequest

typedef GPB_ENUM(UpdateLogMetricRequest_FieldNumber) {
  UpdateLogMetricRequest_FieldNumber_MetricName = 1,
  UpdateLogMetricRequest_FieldNumber_Metric = 2,
};

// The parameters to UpdateLogMetric.
@interface UpdateLogMetricRequest : GPBMessage

// The resource name of the metric to update.
// Example: `"projects/my-project-id/metrics/my-metric-id"`.
//
// The updated metric must be provided in the request and have the
// same identifier that is specified in `metricName`.
// If the metric does not exist, it is created.
@property(nonatomic, readwrite, copy, null_resettable) NSString *metricName;

// The updated metric, whose name must be the same as the
// metric identifier in `metricName`. If `metricName` does not
// exist, then a new metric is created.
@property(nonatomic, readwrite) BOOL hasMetric;
@property(nonatomic, readwrite, strong, null_resettable) LogMetric *metric;

@end

#pragma mark - DeleteLogMetricRequest

typedef GPB_ENUM(DeleteLogMetricRequest_FieldNumber) {
  DeleteLogMetricRequest_FieldNumber_MetricName = 1,
};

// The parameters to DeleteLogMetric.
@interface DeleteLogMetricRequest : GPBMessage

// The resource name of the metric to delete.
// Example: `"projects/my-project-id/metrics/my-metric-id"`.
@property(nonatomic, readwrite, copy, null_resettable) NSString *metricName;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

// @@protoc_insertion_point(global_scope)