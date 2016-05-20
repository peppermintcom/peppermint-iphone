#import "google/logging/v2/Logging.pbobjc.h"

#import <ProtoRPC/ProtoService.h>
#import <RxLibrary/GRXWriteable.h>
#import <RxLibrary/GRXWriter.h>

#import "google/api/Annotations.pbobjc.h"
#import "google/api/MonitoredResource.pbobjc.h"
#import "google/logging/v2/LogEntry.pbobjc.h"
#import "google/protobuf/Empty.pbobjc.h"
#import "google/rpc/Status.pbobjc.h"

@protocol LoggingServiceV2 <NSObject>

#pragma mark DeleteLog(DeleteLogRequest) returns (Empty)

- (void)deleteLogWithRequest:(DeleteLogRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler;

- (ProtoRPC *)RPCToDeleteLogWithRequest:(DeleteLogRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler;


#pragma mark WriteLogEntries(WriteLogEntriesRequest) returns (WriteLogEntriesResponse)

- (void)writeLogEntriesWithRequest:(WriteLogEntriesRequest *)request handler:(void(^)(WriteLogEntriesResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToWriteLogEntriesWithRequest:(WriteLogEntriesRequest *)request handler:(void(^)(WriteLogEntriesResponse *response, NSError *error))handler;


#pragma mark ListLogEntries(ListLogEntriesRequest) returns (ListLogEntriesResponse)

- (void)listLogEntriesWithRequest:(ListLogEntriesRequest *)request handler:(void(^)(ListLogEntriesResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToListLogEntriesWithRequest:(ListLogEntriesRequest *)request handler:(void(^)(ListLogEntriesResponse *response, NSError *error))handler;


#pragma mark ListMonitoredResourceDescriptors(ListMonitoredResourceDescriptorsRequest) returns (ListMonitoredResourceDescriptorsResponse)

- (void)listMonitoredResourceDescriptorsWithRequest:(ListMonitoredResourceDescriptorsRequest *)request handler:(void(^)(ListMonitoredResourceDescriptorsResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToListMonitoredResourceDescriptorsWithRequest:(ListMonitoredResourceDescriptorsRequest *)request handler:(void(^)(ListMonitoredResourceDescriptorsResponse *response, NSError *error))handler;


@end

// Basic service implementation, over gRPC, that only does marshalling and parsing.
@interface LoggingServiceV2 : ProtoService<LoggingServiceV2>
- (instancetype)initWithHost:(NSString *)host NS_DESIGNATED_INITIALIZER;
+ (instancetype)serviceWithHost:(NSString *)host;
@end
