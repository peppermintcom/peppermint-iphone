// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: google/iam/v1/iam_policy.proto

#import "GPBProtocolBuffers.h"

#if GOOGLE_PROTOBUF_OBJC_GEN_VERSION != 30000
#error This file was generated by a different version of protoc which is incompatible with your Protocol Buffer library sources.
#endif

// @@protoc_insertion_point(imports)

CF_EXTERN_C_BEGIN

@class Policy;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - IamPolicyRoot

@interface IamPolicyRoot : GPBRootObject

// The base class provides:
//   + (GPBExtensionRegistry *)extensionRegistry;
// which is an GPBExtensionRegistry that includes all the extensions defined by
// this file and all files that it depends on.

@end

#pragma mark - SetIamPolicyRequest

typedef GPB_ENUM(SetIamPolicyRequest_FieldNumber) {
  SetIamPolicyRequest_FieldNumber_Resource = 1,
  SetIamPolicyRequest_FieldNumber_Policy = 2,
};

// Request message for `SetIamPolicy` method.
@interface SetIamPolicyRequest : GPBMessage

// REQUIRED: The resource for which policy is being specified.
// Resource is usually specified as a path, such as,
// projects/{project}/zones/{zone}/disks/{disk}.
@property(nonatomic, readwrite, copy, null_resettable) NSString *resource;

// REQUIRED: The complete policy to be applied to the 'resource'. The size of
// the policy is limited to a few 10s of KB. An empty policy is in general a
// valid policy but certain services (like Projects) might reject them.
@property(nonatomic, readwrite) BOOL hasPolicy;
@property(nonatomic, readwrite, strong, null_resettable) Policy *policy;

@end

#pragma mark - GetIamPolicyRequest

typedef GPB_ENUM(GetIamPolicyRequest_FieldNumber) {
  GetIamPolicyRequest_FieldNumber_Resource = 1,
};

// Request message for `GetIamPolicy` method.
@interface GetIamPolicyRequest : GPBMessage

// REQUIRED: The resource for which policy is being requested. Resource
// is usually specified as a path, such as, projects/{project}.
@property(nonatomic, readwrite, copy, null_resettable) NSString *resource;

@end

#pragma mark - TestIamPermissionsRequest

typedef GPB_ENUM(TestIamPermissionsRequest_FieldNumber) {
  TestIamPermissionsRequest_FieldNumber_Resource = 1,
  TestIamPermissionsRequest_FieldNumber_PermissionsArray = 2,
};

// Request message for `TestIamPermissions` method.
@interface TestIamPermissionsRequest : GPBMessage

// REQUIRED: The resource for which policy detail is being requested.
// Resource is usually specified as a path, such as, projects/{project}.
@property(nonatomic, readwrite, copy, null_resettable) NSString *resource;

// The set of permissions to check for the 'resource'. Permissions with
// wildcards (such as '*' or 'storage.*') are not allowed.
// |permissionsArray| contains |NSString|
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray *permissionsArray;
@property(nonatomic, readonly) NSUInteger permissionsArray_Count;

@end

#pragma mark - TestIamPermissionsResponse

typedef GPB_ENUM(TestIamPermissionsResponse_FieldNumber) {
  TestIamPermissionsResponse_FieldNumber_PermissionsArray = 1,
};

// Response message for `TestIamPermissions` method.
@interface TestIamPermissionsResponse : GPBMessage

// A subset of `TestPermissionsRequest.permissions` that the caller is
// allowed.
// |permissionsArray| contains |NSString|
@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray *permissionsArray;
@property(nonatomic, readonly) NSUInteger permissionsArray_Count;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

// @@protoc_insertion_point(global_scope)
