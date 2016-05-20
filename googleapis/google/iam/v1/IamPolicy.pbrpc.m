#import "google/iam/v1/IamPolicy.pbrpc.h"

#import <ProtoRPC/ProtoRPC.h>
#import <RxLibrary/GRXWriter+Immediate.h>

static NSString *const kPackageName = @"google.iam.v1";
static NSString *const kServiceName = @"IAMPolicy";

@implementation IAMPolicy

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


#pragma mark SetIamPolicy(SetIamPolicyRequest) returns (Policy)

- (void)setIamPolicyWithRequest:(SetIamPolicyRequest *)request handler:(void(^)(Policy *response, NSError *error))handler{
  [[self RPCToSetIamPolicyWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToSetIamPolicyWithRequest:(SetIamPolicyRequest *)request handler:(void(^)(Policy *response, NSError *error))handler{
  return [self RPCToMethod:@"SetIamPolicy"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Policy class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark GetIamPolicy(GetIamPolicyRequest) returns (Policy)

- (void)getIamPolicyWithRequest:(GetIamPolicyRequest *)request handler:(void(^)(Policy *response, NSError *error))handler{
  [[self RPCToGetIamPolicyWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToGetIamPolicyWithRequest:(GetIamPolicyRequest *)request handler:(void(^)(Policy *response, NSError *error))handler{
  return [self RPCToMethod:@"GetIamPolicy"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Policy class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark TestIamPermissions(TestIamPermissionsRequest) returns (TestIamPermissionsResponse)

- (void)testIamPermissionsWithRequest:(TestIamPermissionsRequest *)request handler:(void(^)(TestIamPermissionsResponse *response, NSError *error))handler{
  [[self RPCToTestIamPermissionsWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToTestIamPermissionsWithRequest:(TestIamPermissionsRequest *)request handler:(void(^)(TestIamPermissionsResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"TestIamPermissions"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[TestIamPermissionsResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
@end
