// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: google/type/timeofday.proto

#import "GPBProtocolBuffers.h"

#if GOOGLE_PROTOBUF_OBJC_GEN_VERSION != 30000
#error This file was generated by a different version of protoc which is incompatible with your Protocol Buffer library sources.
#endif

// @@protoc_insertion_point(imports)

CF_EXTERN_C_BEGIN

NS_ASSUME_NONNULL_BEGIN

#pragma mark - TimeofdayRoot

@interface TimeofdayRoot : GPBRootObject

// The base class provides:
//   + (GPBExtensionRegistry *)extensionRegistry;
// which is an GPBExtensionRegistry that includes all the extensions defined by
// this file and all files that it depends on.

@end

#pragma mark - TimeOfDay

typedef GPB_ENUM(TimeOfDay_FieldNumber) {
  TimeOfDay_FieldNumber_Hours = 1,
  TimeOfDay_FieldNumber_Minutes = 2,
  TimeOfDay_FieldNumber_Seconds = 3,
  TimeOfDay_FieldNumber_Nanos = 4,
};

// Represents a time of day. The date and time zone are either not significant
// or are specified elsewhere. An API may chose to allow leap seconds. Related
// types are [google.type.Date][google.type.Date] and [google.protobuf.Timestamp][google.protobuf.Timestamp].
@interface TimeOfDay : GPBMessage

// Hours of day in 24 hour format. Should be from 0 to 23. An API may choose
// to allow the value "24:00:00" for scenarios like business closing time.
@property(nonatomic, readwrite) int32_t hours;

// Minutes of hour of day. Must be from 0 to 59.
@property(nonatomic, readwrite) int32_t minutes;

// Seconds of minutes of the time. Must normally be from 0 to 59. An API may
// allow the value 60 if it allows leap-seconds.
@property(nonatomic, readwrite) int32_t seconds;

// Fractions of seconds in nanoseconds. Must be from 0 to 999,999,999.
@property(nonatomic, readwrite) int32_t nanos;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

// @@protoc_insertion_point(global_scope)