// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: google/rpc/error_details.proto

#import "GPBProtocolBuffers_RuntimeSupport.h"
#import "google/rpc/ErrorDetails.pbobjc.h"
#import "google/protobuf/Duration.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma mark - ErrorDetailsRoot

@implementation ErrorDetailsRoot

+ (GPBExtensionRegistry*)extensionRegistry {
  // This is called by +initialize so there is no need to worry
  // about thread safety and initialization of registry.
  static GPBExtensionRegistry* registry = nil;
  if (!registry) {
    GPBDebugCheckRuntimeVersion();
    registry = [[GPBExtensionRegistry alloc] init];
    [registry addExtensions:[GPBDurationRoot extensionRegistry]];
  }
  return registry;
}

@end

#pragma mark - ErrorDetailsRoot_FileDescriptor

static GPBFileDescriptor *ErrorDetailsRoot_FileDescriptor(void) {
  // This is called by +initialize so there is no need to worry
  // about thread safety of the singleton.
  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPBDebugCheckRuntimeVersion();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@"google.rpc"
                                                     syntax:GPBFileSyntaxProto3];
  }
  return descriptor;
}

#pragma mark - RetryInfo

@implementation RetryInfo

@dynamic hasRetryDelay, retryDelay;

typedef struct RetryInfo__storage_ {
  uint32_t _has_storage_[1];
  GPBDuration *retryDelay;
} RetryInfo__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "retryDelay",
        .number = RetryInfo_FieldNumber_RetryDelay,
        .hasIndex = 0,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
        .offset = offsetof(RetryInfo__storage_, retryDelay),
        .defaultValue.valueMessage = nil,
        .dataTypeSpecific.className = GPBStringifySymbol(GPBDuration),
        .fieldOptions = NULL,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[RetryInfo class]
                                     rootClass:[ErrorDetailsRoot class]
                                          file:ErrorDetailsRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:sizeof(fields) / sizeof(GPBMessageFieldDescription)
                                        oneofs:NULL
                                    oneofCount:0
                                         enums:NULL
                                     enumCount:0
                                        ranges:NULL
                                    rangeCount:0
                                   storageSize:sizeof(RetryInfo__storage_)
                                    wireFormat:NO];
    NSAssert(descriptor == nil, @"Startup recursed!");
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - DebugInfo

@implementation DebugInfo

@dynamic stackEntriesArray, stackEntriesArray_Count;
@dynamic detail;

typedef struct DebugInfo__storage_ {
  uint32_t _has_storage_[1];
  NSMutableArray *stackEntriesArray;
  NSString *detail;
} DebugInfo__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "stackEntriesArray",
        .number = DebugInfo_FieldNumber_StackEntriesArray,
        .hasIndex = GPBNoHasBit,
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeString,
        .offset = offsetof(DebugInfo__storage_, stackEntriesArray),
        .defaultValue.valueMessage = nil,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
      {
        .name = "detail",
        .number = DebugInfo_FieldNumber_Detail,
        .hasIndex = 1,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
        .offset = offsetof(DebugInfo__storage_, detail),
        .defaultValue.valueString = nil,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[DebugInfo class]
                                     rootClass:[ErrorDetailsRoot class]
                                          file:ErrorDetailsRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:sizeof(fields) / sizeof(GPBMessageFieldDescription)
                                        oneofs:NULL
                                    oneofCount:0
                                         enums:NULL
                                     enumCount:0
                                        ranges:NULL
                                    rangeCount:0
                                   storageSize:sizeof(DebugInfo__storage_)
                                    wireFormat:NO];
    NSAssert(descriptor == nil, @"Startup recursed!");
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - QuotaFailure

@implementation QuotaFailure

@dynamic violationsArray, violationsArray_Count;

typedef struct QuotaFailure__storage_ {
  uint32_t _has_storage_[1];
  NSMutableArray *violationsArray;
} QuotaFailure__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "violationsArray",
        .number = QuotaFailure_FieldNumber_ViolationsArray,
        .hasIndex = GPBNoHasBit,
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeMessage,
        .offset = offsetof(QuotaFailure__storage_, violationsArray),
        .defaultValue.valueMessage = nil,
        .dataTypeSpecific.className = GPBStringifySymbol(QuotaFailure_Violation),
        .fieldOptions = NULL,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[QuotaFailure class]
                                     rootClass:[ErrorDetailsRoot class]
                                          file:ErrorDetailsRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:sizeof(fields) / sizeof(GPBMessageFieldDescription)
                                        oneofs:NULL
                                    oneofCount:0
                                         enums:NULL
                                     enumCount:0
                                        ranges:NULL
                                    rangeCount:0
                                   storageSize:sizeof(QuotaFailure__storage_)
                                    wireFormat:NO];
    NSAssert(descriptor == nil, @"Startup recursed!");
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - QuotaFailure_Violation

@implementation QuotaFailure_Violation

@dynamic subject;
@dynamic description_p;

typedef struct QuotaFailure_Violation__storage_ {
  uint32_t _has_storage_[1];
  NSString *subject;
  NSString *description_p;
} QuotaFailure_Violation__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "subject",
        .number = QuotaFailure_Violation_FieldNumber_Subject,
        .hasIndex = 0,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
        .offset = offsetof(QuotaFailure_Violation__storage_, subject),
        .defaultValue.valueString = nil,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
      {
        .name = "description_p",
        .number = QuotaFailure_Violation_FieldNumber_Description_p,
        .hasIndex = 1,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
        .offset = offsetof(QuotaFailure_Violation__storage_, description_p),
        .defaultValue.valueString = nil,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[QuotaFailure_Violation class]
                                     rootClass:[ErrorDetailsRoot class]
                                          file:ErrorDetailsRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:sizeof(fields) / sizeof(GPBMessageFieldDescription)
                                        oneofs:NULL
                                    oneofCount:0
                                         enums:NULL
                                     enumCount:0
                                        ranges:NULL
                                    rangeCount:0
                                   storageSize:sizeof(QuotaFailure_Violation__storage_)
                                    wireFormat:NO];
    NSAssert(descriptor == nil, @"Startup recursed!");
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - BadRequest

@implementation BadRequest

@dynamic fieldViolationsArray, fieldViolationsArray_Count;

typedef struct BadRequest__storage_ {
  uint32_t _has_storage_[1];
  NSMutableArray *fieldViolationsArray;
} BadRequest__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "fieldViolationsArray",
        .number = BadRequest_FieldNumber_FieldViolationsArray,
        .hasIndex = GPBNoHasBit,
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeMessage,
        .offset = offsetof(BadRequest__storage_, fieldViolationsArray),
        .defaultValue.valueMessage = nil,
        .dataTypeSpecific.className = GPBStringifySymbol(BadRequest_FieldViolation),
        .fieldOptions = NULL,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[BadRequest class]
                                     rootClass:[ErrorDetailsRoot class]
                                          file:ErrorDetailsRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:sizeof(fields) / sizeof(GPBMessageFieldDescription)
                                        oneofs:NULL
                                    oneofCount:0
                                         enums:NULL
                                     enumCount:0
                                        ranges:NULL
                                    rangeCount:0
                                   storageSize:sizeof(BadRequest__storage_)
                                    wireFormat:NO];
    NSAssert(descriptor == nil, @"Startup recursed!");
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - BadRequest_FieldViolation

@implementation BadRequest_FieldViolation

@dynamic field;
@dynamic description_p;

typedef struct BadRequest_FieldViolation__storage_ {
  uint32_t _has_storage_[1];
  NSString *field;
  NSString *description_p;
} BadRequest_FieldViolation__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "field",
        .number = BadRequest_FieldViolation_FieldNumber_Field,
        .hasIndex = 0,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
        .offset = offsetof(BadRequest_FieldViolation__storage_, field),
        .defaultValue.valueString = nil,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
      {
        .name = "description_p",
        .number = BadRequest_FieldViolation_FieldNumber_Description_p,
        .hasIndex = 1,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
        .offset = offsetof(BadRequest_FieldViolation__storage_, description_p),
        .defaultValue.valueString = nil,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[BadRequest_FieldViolation class]
                                     rootClass:[ErrorDetailsRoot class]
                                          file:ErrorDetailsRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:sizeof(fields) / sizeof(GPBMessageFieldDescription)
                                        oneofs:NULL
                                    oneofCount:0
                                         enums:NULL
                                     enumCount:0
                                        ranges:NULL
                                    rangeCount:0
                                   storageSize:sizeof(BadRequest_FieldViolation__storage_)
                                    wireFormat:NO];
    NSAssert(descriptor == nil, @"Startup recursed!");
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - RequestInfo

@implementation RequestInfo

@dynamic requestId;
@dynamic servingData;

typedef struct RequestInfo__storage_ {
  uint32_t _has_storage_[1];
  NSString *requestId;
  NSString *servingData;
} RequestInfo__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "requestId",
        .number = RequestInfo_FieldNumber_RequestId,
        .hasIndex = 0,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
        .offset = offsetof(RequestInfo__storage_, requestId),
        .defaultValue.valueString = nil,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
      {
        .name = "servingData",
        .number = RequestInfo_FieldNumber_ServingData,
        .hasIndex = 1,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
        .offset = offsetof(RequestInfo__storage_, servingData),
        .defaultValue.valueString = nil,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[RequestInfo class]
                                     rootClass:[ErrorDetailsRoot class]
                                          file:ErrorDetailsRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:sizeof(fields) / sizeof(GPBMessageFieldDescription)
                                        oneofs:NULL
                                    oneofCount:0
                                         enums:NULL
                                     enumCount:0
                                        ranges:NULL
                                    rangeCount:0
                                   storageSize:sizeof(RequestInfo__storage_)
                                    wireFormat:NO];
    NSAssert(descriptor == nil, @"Startup recursed!");
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - ResourceInfo

@implementation ResourceInfo

@dynamic resourceType;
@dynamic resourceName;
@dynamic owner;
@dynamic description_p;

typedef struct ResourceInfo__storage_ {
  uint32_t _has_storage_[1];
  NSString *resourceType;
  NSString *resourceName;
  NSString *owner;
  NSString *description_p;
} ResourceInfo__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "resourceType",
        .number = ResourceInfo_FieldNumber_ResourceType,
        .hasIndex = 0,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
        .offset = offsetof(ResourceInfo__storage_, resourceType),
        .defaultValue.valueString = nil,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
      {
        .name = "resourceName",
        .number = ResourceInfo_FieldNumber_ResourceName,
        .hasIndex = 1,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
        .offset = offsetof(ResourceInfo__storage_, resourceName),
        .defaultValue.valueString = nil,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
      {
        .name = "owner",
        .number = ResourceInfo_FieldNumber_Owner,
        .hasIndex = 2,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
        .offset = offsetof(ResourceInfo__storage_, owner),
        .defaultValue.valueString = nil,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
      {
        .name = "description_p",
        .number = ResourceInfo_FieldNumber_Description_p,
        .hasIndex = 3,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
        .offset = offsetof(ResourceInfo__storage_, description_p),
        .defaultValue.valueString = nil,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[ResourceInfo class]
                                     rootClass:[ErrorDetailsRoot class]
                                          file:ErrorDetailsRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:sizeof(fields) / sizeof(GPBMessageFieldDescription)
                                        oneofs:NULL
                                    oneofCount:0
                                         enums:NULL
                                     enumCount:0
                                        ranges:NULL
                                    rangeCount:0
                                   storageSize:sizeof(ResourceInfo__storage_)
                                    wireFormat:NO];
    NSAssert(descriptor == nil, @"Startup recursed!");
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - Help

@implementation Help

@dynamic linksArray, linksArray_Count;

typedef struct Help__storage_ {
  uint32_t _has_storage_[1];
  NSMutableArray *linksArray;
} Help__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "linksArray",
        .number = Help_FieldNumber_LinksArray,
        .hasIndex = GPBNoHasBit,
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeMessage,
        .offset = offsetof(Help__storage_, linksArray),
        .defaultValue.valueMessage = nil,
        .dataTypeSpecific.className = GPBStringifySymbol(Help_Link),
        .fieldOptions = NULL,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[Help class]
                                     rootClass:[ErrorDetailsRoot class]
                                          file:ErrorDetailsRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:sizeof(fields) / sizeof(GPBMessageFieldDescription)
                                        oneofs:NULL
                                    oneofCount:0
                                         enums:NULL
                                     enumCount:0
                                        ranges:NULL
                                    rangeCount:0
                                   storageSize:sizeof(Help__storage_)
                                    wireFormat:NO];
    NSAssert(descriptor == nil, @"Startup recursed!");
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - Help_Link

@implementation Help_Link

@dynamic description_p;
@dynamic uRL;

typedef struct Help_Link__storage_ {
  uint32_t _has_storage_[1];
  NSString *description_p;
  NSString *uRL;
} Help_Link__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "description_p",
        .number = Help_Link_FieldNumber_Description_p,
        .hasIndex = 0,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
        .offset = offsetof(Help_Link__storage_, description_p),
        .defaultValue.valueString = nil,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
      {
        .name = "uRL",
        .number = Help_Link_FieldNumber_URL,
        .hasIndex = 1,
        .flags = GPBFieldOptional | GPBFieldTextFormatNameCustom,
        .dataType = GPBDataTypeString,
        .offset = offsetof(Help_Link__storage_, uRL),
        .defaultValue.valueString = nil,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
    };
#if GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    const char *extraTextFormatInfo = NULL;
#else
    static const char *extraTextFormatInfo = "\001\002\001!!\000";
#endif  // GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[Help_Link class]
                                     rootClass:[ErrorDetailsRoot class]
                                          file:ErrorDetailsRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:sizeof(fields) / sizeof(GPBMessageFieldDescription)
                                        oneofs:NULL
                                    oneofCount:0
                                         enums:NULL
                                     enumCount:0
                                        ranges:NULL
                                    rangeCount:0
                                   storageSize:sizeof(Help_Link__storage_)
                                    wireFormat:NO
                           extraTextFormatInfo:extraTextFormatInfo];
    NSAssert(descriptor == nil, @"Startup recursed!");
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


// @@protoc_insertion_point(global_scope)
