// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: google/api/annotations.proto

#import "GPBProtocolBuffers_RuntimeSupport.h"
#import "google/api/Annotations.pbobjc.h"
#import "google/api/HTTP.pbobjc.h"
#import "google/protobuf/Descriptor.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma mark - AnnotationsRoot

@implementation AnnotationsRoot

+ (GPBExtensionRegistry*)extensionRegistry {
  // This is called by +initialize so there is no need to worry
  // about thread safety and initialization of registry.
  static GPBExtensionRegistry* registry = nil;
  if (!registry) {
    GPBDebugCheckRuntimeVersion();
    registry = [[GPBExtensionRegistry alloc] init];
    static GPBExtensionDescription descriptions[] = {
      {
        .singletonName = GPBStringifySymbol(AnnotationsRoot_hTTP),
        .dataType = GPBDataTypeMessage,
        .extendedClass = GPBStringifySymbol(GPBMethodOptions),
        .fieldNumber = 72295728,
        .defaultValue.valueMessage = nil,
        .messageOrGroupClassName = GPBStringifySymbol(HttpRule),
        .options = 0,
        .enumDescriptorFunc = NULL,
      },
    };
    for (size_t i = 0; i < sizeof(descriptions) / sizeof(descriptions[0]); ++i) {
      GPBExtensionDescriptor *extension =
          [[GPBExtensionDescriptor alloc] initWithExtensionDescription:&descriptions[i]];
      [registry addExtension:extension];
      [self globallyRegisterExtension:extension];
      [extension release];
    }
    [registry addExtensions:[HTTPRoot extensionRegistry]];
    [registry addExtensions:[GPBDescriptorRoot extensionRegistry]];
  }
  return registry;
}

@end


// @@protoc_insertion_point(global_scope)
