// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: google/logging/type/http_request.proto

#import "GPBProtocolBuffers_RuntimeSupport.h"
#import "google/logging/type/HTTPRequest.pbobjc.h"
#import "google/api/Annotations.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma mark - HTTPRequestRoot

@implementation HTTPRequestRoot

+ (GPBExtensionRegistry*)extensionRegistry {
  // This is called by +initialize so there is no need to worry
  // about thread safety and initialization of registry.
  static GPBExtensionRegistry* registry = nil;
  if (!registry) {
    GPBDebugCheckRuntimeVersion();
    registry = [[GPBExtensionRegistry alloc] init];
    [registry addExtensions:[AnnotationsRoot extensionRegistry]];
  }
  return registry;
}

@end

#pragma mark - HTTPRequestRoot_FileDescriptor

static GPBFileDescriptor *HTTPRequestRoot_FileDescriptor(void) {
  // This is called by +initialize so there is no need to worry
  // about thread safety of the singleton.
  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPBDebugCheckRuntimeVersion();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@"google.logging.type"
                                                     syntax:GPBFileSyntaxProto3];
  }
  return descriptor;
}

#pragma mark - HttpRequest

@implementation HttpRequest

@dynamic requestMethod;
@dynamic requestURL;
@dynamic requestSize;
@dynamic status;
@dynamic responseSize;
@dynamic userAgent;
@dynamic remoteIp;
@dynamic referer;
@dynamic cacheHit;
@dynamic validatedWithOriginServer;

typedef struct HttpRequest__storage_ {
  uint32_t _has_storage_[1];
  BOOL cacheHit;
  BOOL validatedWithOriginServer;
  int32_t status;
  NSString *requestMethod;
  NSString *requestURL;
  NSString *userAgent;
  NSString *remoteIp;
  NSString *referer;
  int64_t requestSize;
  int64_t responseSize;
} HttpRequest__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "requestMethod",
        .number = HttpRequest_FieldNumber_RequestMethod,
        .hasIndex = 0,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
        .offset = offsetof(HttpRequest__storage_, requestMethod),
        .defaultValue.valueString = nil,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
      {
        .name = "requestURL",
        .number = HttpRequest_FieldNumber_RequestURL,
        .hasIndex = 1,
        .flags = GPBFieldOptional | GPBFieldTextFormatNameCustom,
        .dataType = GPBDataTypeString,
        .offset = offsetof(HttpRequest__storage_, requestURL),
        .defaultValue.valueString = nil,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
      {
        .name = "requestSize",
        .number = HttpRequest_FieldNumber_RequestSize,
        .hasIndex = 2,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt64,
        .offset = offsetof(HttpRequest__storage_, requestSize),
        .defaultValue.valueInt64 = 0LL,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
      {
        .name = "status",
        .number = HttpRequest_FieldNumber_Status,
        .hasIndex = 3,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
        .offset = offsetof(HttpRequest__storage_, status),
        .defaultValue.valueInt32 = 0,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
      {
        .name = "responseSize",
        .number = HttpRequest_FieldNumber_ResponseSize,
        .hasIndex = 4,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt64,
        .offset = offsetof(HttpRequest__storage_, responseSize),
        .defaultValue.valueInt64 = 0LL,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
      {
        .name = "userAgent",
        .number = HttpRequest_FieldNumber_UserAgent,
        .hasIndex = 5,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
        .offset = offsetof(HttpRequest__storage_, userAgent),
        .defaultValue.valueString = nil,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
      {
        .name = "remoteIp",
        .number = HttpRequest_FieldNumber_RemoteIp,
        .hasIndex = 6,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
        .offset = offsetof(HttpRequest__storage_, remoteIp),
        .defaultValue.valueString = nil,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
      {
        .name = "referer",
        .number = HttpRequest_FieldNumber_Referer,
        .hasIndex = 7,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
        .offset = offsetof(HttpRequest__storage_, referer),
        .defaultValue.valueString = nil,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
      {
        .name = "cacheHit",
        .number = HttpRequest_FieldNumber_CacheHit,
        .hasIndex = 8,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBool,
        .offset = offsetof(HttpRequest__storage_, cacheHit),
        .defaultValue.valueBool = NO,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
      {
        .name = "validatedWithOriginServer",
        .number = HttpRequest_FieldNumber_ValidatedWithOriginServer,
        .hasIndex = 9,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBool,
        .offset = offsetof(HttpRequest__storage_, validatedWithOriginServer),
        .defaultValue.valueBool = NO,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
    };
#if GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    const char *extraTextFormatInfo = NULL;
#else
    static const char *extraTextFormatInfo = "\001\002\007\241!!\000";
#endif  // GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[HttpRequest class]
                                     rootClass:[HTTPRequestRoot class]
                                          file:HTTPRequestRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:sizeof(fields) / sizeof(GPBMessageFieldDescription)
                                        oneofs:NULL
                                    oneofCount:0
                                         enums:NULL
                                     enumCount:0
                                        ranges:NULL
                                    rangeCount:0
                                   storageSize:sizeof(HttpRequest__storage_)
                                    wireFormat:NO
                           extraTextFormatInfo:extraTextFormatInfo];
    NSAssert(descriptor == nil, @"Startup recursed!");
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


// @@protoc_insertion_point(global_scope)
