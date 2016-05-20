#import "google/iam/v1/IamPolicy.pbobjc.h"

#import <ProtoRPC/ProtoService.h>
#import <RxLibrary/GRXWriteable.h>
#import <RxLibrary/GRXWriter.h>

#import "google/iam/v1/Policy.pbobjc.h"

@protocol IAMPolicy <NSObject>

#pragma mark SetIamPolicy(SetIamPolicyRequest) returns (Policy)

- (void)setIamPolicyWithRequest:(SetIamPolicyRequest *)request handler:(void(^)(Policy *response, NSError *error))handler;

- (ProtoRPC *)RPCToSetIamPolicyWithRequest:(SetIamPolicyRequest *)request handler:(void(^)(Policy *response, NSError *error))handler;


#pragma mark GetIamPolicy(GetIamPolicyRequest) returns (Policy)

- (void)getIamPolicyWithRequest:(GetIamPolicyRequest *)request handler:(void(^)(Policy *response, NSError *error))handler;

- (ProtoRPC *)RPCToGetIamPolicyWithRequest:(GetIamPolicyRequest *)request handler:(void(^)(Policy *response, NSError *error))handler;


#pragma mark TestIamPermissions(TestIamPermissionsRequest) returns (TestIamPermissionsResponse)

- (void)testIamPermissionsWithRequest:(TestIamPermissionsRequest *)request handler:(void(^)(TestIamPermissionsResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToTestIamPermissionsWithRequest:(TestIamPermissionsRequest *)request handler:(void(^)(TestIamPermissionsResponse *response, NSError *error))handler;


@end

// Basic service implementation, over gRPC, that only does marshalling and parsing.
@interface IAMPolicy : ProtoService<IAMPolicy>
- (instancetype)initWithHost:(NSString *)host NS_DESIGNATED_INITIALIZER;
+ (instancetype)serviceWithHost:(NSString *)host;
@end
