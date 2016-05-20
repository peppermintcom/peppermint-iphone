#import "google/cloud/vision/v1/ImageAnnotator.pbobjc.h"

#import <ProtoRPC/ProtoService.h>
#import <RxLibrary/GRXWriteable.h>
#import <RxLibrary/GRXWriter.h>

#import "google/api/Annotations.pbobjc.h"
#import "google/cloud/vision/v1/Geometry.pbobjc.h"
#import "google/rpc/Status.pbobjc.h"
#import "google/type/Color.pbobjc.h"
#import "google/type/Latlng.pbobjc.h"

@protocol ImageAnnotator <NSObject>

#pragma mark BatchAnnotateImages(BatchAnnotateImagesRequest) returns (BatchAnnotateImagesResponse)

- (void)batchAnnotateImagesWithRequest:(BatchAnnotateImagesRequest *)request handler:(void(^)(BatchAnnotateImagesResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToBatchAnnotateImagesWithRequest:(BatchAnnotateImagesRequest *)request handler:(void(^)(BatchAnnotateImagesResponse *response, NSError *error))handler;


@end

// Basic service implementation, over gRPC, that only does marshalling and parsing.
@interface ImageAnnotator : ProtoService<ImageAnnotator>
- (instancetype)initWithHost:(NSString *)host NS_DESIGNATED_INITIALIZER;
+ (instancetype)serviceWithHost:(NSString *)host;
@end
