#import "google/logging/v2/LoggingConfig.pbobjc.h"

#import <ProtoRPC/ProtoService.h>
#import <RxLibrary/GRXWriteable.h>
#import <RxLibrary/GRXWriter.h>

#import "google/api/Annotations.pbobjc.h"
#import "google/protobuf/Empty.pbobjc.h"
#import "google/protobuf/Timestamp.pbobjc.h"

@protocol ConfigServiceV2 <NSObject>

#pragma mark ListSinks(ListSinksRequest) returns (ListSinksResponse)

- (void)listSinksWithRequest:(ListSinksRequest *)request handler:(void(^)(ListSinksResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToListSinksWithRequest:(ListSinksRequest *)request handler:(void(^)(ListSinksResponse *response, NSError *error))handler;


#pragma mark GetSink(GetSinkRequest) returns (LogSink)

- (void)getSinkWithRequest:(GetSinkRequest *)request handler:(void(^)(LogSink *response, NSError *error))handler;

- (ProtoRPC *)RPCToGetSinkWithRequest:(GetSinkRequest *)request handler:(void(^)(LogSink *response, NSError *error))handler;


#pragma mark CreateSink(CreateSinkRequest) returns (LogSink)

- (void)createSinkWithRequest:(CreateSinkRequest *)request handler:(void(^)(LogSink *response, NSError *error))handler;

- (ProtoRPC *)RPCToCreateSinkWithRequest:(CreateSinkRequest *)request handler:(void(^)(LogSink *response, NSError *error))handler;


#pragma mark UpdateSink(UpdateSinkRequest) returns (LogSink)

- (void)updateSinkWithRequest:(UpdateSinkRequest *)request handler:(void(^)(LogSink *response, NSError *error))handler;

- (ProtoRPC *)RPCToUpdateSinkWithRequest:(UpdateSinkRequest *)request handler:(void(^)(LogSink *response, NSError *error))handler;


#pragma mark DeleteSink(DeleteSinkRequest) returns (Empty)

- (void)deleteSinkWithRequest:(DeleteSinkRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler;

- (ProtoRPC *)RPCToDeleteSinkWithRequest:(DeleteSinkRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler;


@end

// Basic service implementation, over gRPC, that only does marshalling and parsing.
@interface ConfigServiceV2 : ProtoService<ConfigServiceV2>
- (instancetype)initWithHost:(NSString *)host NS_DESIGNATED_INITIALIZER;
+ (instancetype)serviceWithHost:(NSString *)host;
@end
