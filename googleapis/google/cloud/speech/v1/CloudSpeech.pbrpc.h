#import "google/cloud/speech/v1/CloudSpeech.pbobjc.h"

#import <ProtoRPC/ProtoService.h>
#import <RxLibrary/GRXWriteable.h>
#import <RxLibrary/GRXWriter.h>

#import "google/api/Annotations.pbobjc.h"
#import "google/rpc/Status.pbobjc.h"

@protocol Speech <NSObject>

#pragma mark Recognize(stream RecognizeRequest) returns (stream RecognizeResponse)

- (void)recognizeWithRequestsWriter:(GRXWriter *)requestWriter eventHandler:(void(^)(BOOL done, RecognizeResponse *response, NSError *error))eventHandler;

- (ProtoRPC *)RPCToRecognizeWithRequestsWriter:(GRXWriter *)requestWriter eventHandler:(void(^)(BOOL done, RecognizeResponse *response, NSError *error))eventHandler;


#pragma mark NonStreamingRecognize(RecognizeRequest) returns (NonStreamingRecognizeResponse)

- (void)nonStreamingRecognizeWithRequest:(RecognizeRequest *)request handler:(void(^)(NonStreamingRecognizeResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToNonStreamingRecognizeWithRequest:(RecognizeRequest *)request handler:(void(^)(NonStreamingRecognizeResponse *response, NSError *error))handler;


@end

// Basic service implementation, over gRPC, that only does marshalling and parsing.
@interface Speech : ProtoService<Speech>
- (instancetype)initWithHost:(NSString *)host NS_DESIGNATED_INITIALIZER;
+ (instancetype)serviceWithHost:(NSString *)host;
@end
