#import "google/cloud/vision/v1/ImageAnnotator.pbrpc.h"

#import <ProtoRPC/ProtoRPC.h>
#import <RxLibrary/GRXWriter+Immediate.h>

static NSString *const kPackageName = @"google.cloud.vision.v1";
static NSString *const kServiceName = @"ImageAnnotator";

@implementation ImageAnnotator

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


#pragma mark BatchAnnotateImages(BatchAnnotateImagesRequest) returns (BatchAnnotateImagesResponse)

- (void)batchAnnotateImagesWithRequest:(BatchAnnotateImagesRequest *)request handler:(void(^)(BatchAnnotateImagesResponse *response, NSError *error))handler{
  [[self RPCToBatchAnnotateImagesWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToBatchAnnotateImagesWithRequest:(BatchAnnotateImagesRequest *)request handler:(void(^)(BatchAnnotateImagesResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"BatchAnnotateImages"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[BatchAnnotateImagesResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
@end
