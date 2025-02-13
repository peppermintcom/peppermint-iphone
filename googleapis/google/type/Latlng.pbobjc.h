// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: google/type/latlng.proto

#import "GPBProtocolBuffers.h"

#if GOOGLE_PROTOBUF_OBJC_GEN_VERSION != 30000
#error This file was generated by a different version of protoc which is incompatible with your Protocol Buffer library sources.
#endif

// @@protoc_insertion_point(imports)

CF_EXTERN_C_BEGIN

NS_ASSUME_NONNULL_BEGIN

#pragma mark - LatlngRoot

@interface LatlngRoot : GPBRootObject

// The base class provides:
//   + (GPBExtensionRegistry *)extensionRegistry;
// which is an GPBExtensionRegistry that includes all the extensions defined by
// this file and all files that it depends on.

@end

#pragma mark - LatLng

typedef GPB_ENUM(LatLng_FieldNumber) {
  LatLng_FieldNumber_Latitude = 1,
  LatLng_FieldNumber_Longitude = 2,
};

// An object representing a latitude/longitude pair. This is expressed as a pair
// of doubles representing degrees latitude and degrees longitude. Unless
// specified otherwise, this must conform to the
// <a href="http://www.unoosa.org/pdf/icg/2012/template/WGS_84.pdf">WGS84
// standard</a>. Values must be within normalized ranges.
@interface LatLng : GPBMessage

// The latitude in degrees. It must be in the range [-90.0, +90.0].
@property(nonatomic, readwrite) double latitude;

// The longitude in degrees. It must be in the range [-180.0, +180.0].
@property(nonatomic, readwrite) double longitude;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

// @@protoc_insertion_point(global_scope)
