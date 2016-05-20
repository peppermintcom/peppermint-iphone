#import "google/cloud/speech/v1/CloudSpeech.pbrpc.h"

#import <ProtoRPC/ProtoRPC.h>
#import <RxLibrary/GRXWriter+Immediate.h>

static NSString *const kPackageName = @"google.cloud.speech.v1";
static NSString *const kServiceName = @"Speech";

@implementation Speech

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


#pragma mark Recognize(stream RecognizeRequest) returns (stream RecognizeResponse)

- (void)recognizeWithRequestsWriter:(GRXWriter *)requestWriter eventHandler:(void(^)(BOOL done, RecognizeResponse *response, NSError *error))eventHandler{
  [[self RPCToRecognizeWithRequestsWriter:requestWriter eventHandler:eventHandler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToRecognizeWithRequestsWriter:(GRXWriter *)requestWriter eventHandler:(void(^)(BOOL done, RecognizeResponse *response, NSError *error))eventHandler{
  return [self RPCToMethod:@"Recognize"
            requestsWriter:requestWriter
             responseClass:[RecognizeResponse class]
        responsesWriteable:[GRXWriteable writeableWithEventHandler:eventHandler]];
}
#pragma mark NonStreamingRecognize(RecognizeRequest) returns (NonStreamingRecognizeResponse)

- (void)nonStreamingRecognizeWithRequest:(RecognizeRequest *)request handler:(void(^)(NonStreamingRecognizeResponse *response, NSError *error))handler{
  [[self RPCToNonStreamingRecognizeWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToNonStreamingRecognizeWithRequest:(RecognizeRequest *)request handler:(void(^)(NonStreamingRecognizeResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"NonStreamingRecognize"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[NonStreamingRecognizeResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
@end
