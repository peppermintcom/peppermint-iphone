// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: google/type/timeofday.proto

#import "GPBProtocolBuffers_RuntimeSupport.h"
#import "google/type/Timeofday.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma mark - TimeofdayRoot

@implementation TimeofdayRoot

@end

#pragma mark - TimeofdayRoot_FileDescriptor

static GPBFileDescriptor *TimeofdayRoot_FileDescriptor(void) {
  // This is called by +initialize so there is no need to worry
  // about thread safety of the singleton.
  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPBDebugCheckRuntimeVersion();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@"google.type"
                                                     syntax:GPBFileSyntaxProto3];
  }
  return descriptor;
}

#pragma mark - TimeOfDay

@implementation TimeOfDay

@dynamic hours;
@dynamic minutes;
@dynamic seconds;
@dynamic nanos;

typedef struct TimeOfDay__storage_ {
  uint32_t _has_storage_[1];
  int32_t hours;
  int32_t minutes;
  int32_t seconds;
  int32_t nanos;
} TimeOfDay__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "hours",
        .number = TimeOfDay_FieldNumber_Hours,
        .hasIndex = 0,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
        .offset = offsetof(TimeOfDay__storage_, hours),
        .defaultValue.valueInt32 = 0,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
      {
        .name = "minutes",
        .number = TimeOfDay_FieldNumber_Minutes,
        .hasIndex = 1,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
        .offset = offsetof(TimeOfDay__storage_, minutes),
        .defaultValue.valueInt32 = 0,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
      {
        .name = "seconds",
        .number = TimeOfDay_FieldNumber_Seconds,
        .hasIndex = 2,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
        .offset = offsetof(TimeOfDay__storage_, seconds),
        .defaultValue.valueInt32 = 0,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
      {
        .name = "nanos",
        .number = TimeOfDay_FieldNumber_Nanos,
        .hasIndex = 3,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
        .offset = offsetof(TimeOfDay__storage_, nanos),
        .defaultValue.valueInt32 = 0,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[TimeOfDay class]
                                     rootClass:[TimeofdayRoot class]
                                          file:TimeofdayRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:sizeof(fields) / sizeof(GPBMessageFieldDescription)
                                        oneofs:NULL
                                    oneofCount:0
                                         enums:NULL
                                     enumCount:0
                                        ranges:NULL
                                    rangeCount:0
                                   storageSize:sizeof(TimeOfDay__storage_)
                                    wireFormat:NO];
    NSAssert(descriptor == nil, @"Startup recursed!");
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


// @@protoc_insertion_point(global_scope)