#import "google/example/library/v1/Library.pbrpc.h"

#import <ProtoRPC/ProtoRPC.h>
#import <RxLibrary/GRXWriter+Immediate.h>

static NSString *const kPackageName = @"google.example.library.v1";
static NSString *const kServiceName = @"LibraryService";

@implementation LibraryService

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


#pragma mark CreateShelf(CreateShelfRequest) returns (Shelf)

- (void)createShelfWithRequest:(CreateShelfRequest *)request handler:(void(^)(Shelf *response, NSError *error))handler{
  [[self RPCToCreateShelfWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToCreateShelfWithRequest:(CreateShelfRequest *)request handler:(void(^)(Shelf *response, NSError *error))handler{
  return [self RPCToMethod:@"CreateShelf"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Shelf class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark GetShelf(GetShelfRequest) returns (Shelf)

- (void)getShelfWithRequest:(GetShelfRequest *)request handler:(void(^)(Shelf *response, NSError *error))handler{
  [[self RPCToGetShelfWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToGetShelfWithRequest:(GetShelfRequest *)request handler:(void(^)(Shelf *response, NSError *error))handler{
  return [self RPCToMethod:@"GetShelf"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Shelf class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark ListShelves(ListShelvesRequest) returns (ListShelvesResponse)

- (void)listShelvesWithRequest:(ListShelvesRequest *)request handler:(void(^)(ListShelvesResponse *response, NSError *error))handler{
  [[self RPCToListShelvesWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToListShelvesWithRequest:(ListShelvesRequest *)request handler:(void(^)(ListShelvesResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"ListShelves"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[ListShelvesResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark DeleteShelf(DeleteShelfRequest) returns (Empty)

- (void)deleteShelfWithRequest:(DeleteShelfRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler{
  [[self RPCToDeleteShelfWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToDeleteShelfWithRequest:(DeleteShelfRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler{
  return [self RPCToMethod:@"DeleteShelf"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[GPBEmpty class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark MergeShelves(MergeShelvesRequest) returns (Shelf)

- (void)mergeShelvesWithRequest:(MergeShelvesRequest *)request handler:(void(^)(Shelf *response, NSError *error))handler{
  [[self RPCToMergeShelvesWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToMergeShelvesWithRequest:(MergeShelvesRequest *)request handler:(void(^)(Shelf *response, NSError *error))handler{
  return [self RPCToMethod:@"MergeShelves"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Shelf class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark CreateBook(CreateBookRequest) returns (Book)

- (void)createBookWithRequest:(CreateBookRequest *)request handler:(void(^)(Book *response, NSError *error))handler{
  [[self RPCToCreateBookWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToCreateBookWithRequest:(CreateBookRequest *)request handler:(void(^)(Book *response, NSError *error))handler{
  return [self RPCToMethod:@"CreateBook"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Book class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark GetBook(GetBookRequest) returns (Book)

- (void)getBookWithRequest:(GetBookRequest *)request handler:(void(^)(Book *response, NSError *error))handler{
  [[self RPCToGetBookWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToGetBookWithRequest:(GetBookRequest *)request handler:(void(^)(Book *response, NSError *error))handler{
  return [self RPCToMethod:@"GetBook"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Book class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark ListBooks(ListBooksRequest) returns (ListBooksResponse)

- (void)listBooksWithRequest:(ListBooksRequest *)request handler:(void(^)(ListBooksResponse *response, NSError *error))handler{
  [[self RPCToListBooksWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToListBooksWithRequest:(ListBooksRequest *)request handler:(void(^)(ListBooksResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"ListBooks"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[ListBooksResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark DeleteBook(DeleteBookRequest) returns (Empty)

- (void)deleteBookWithRequest:(DeleteBookRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler{
  [[self RPCToDeleteBookWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToDeleteBookWithRequest:(DeleteBookRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler{
  return [self RPCToMethod:@"DeleteBook"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[GPBEmpty class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark UpdateBook(UpdateBookRequest) returns (Book)

- (void)updateBookWithRequest:(UpdateBookRequest *)request handler:(void(^)(Book *response, NSError *error))handler{
  [[self RPCToUpdateBookWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToUpdateBookWithRequest:(UpdateBookRequest *)request handler:(void(^)(Book *response, NSError *error))handler{
  return [self RPCToMethod:@"UpdateBook"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Book class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark MoveBook(MoveBookRequest) returns (Book)

- (void)moveBookWithRequest:(MoveBookRequest *)request handler:(void(^)(Book *response, NSError *error))handler{
  [[self RPCToMoveBookWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToMoveBookWithRequest:(MoveBookRequest *)request handler:(void(^)(Book *response, NSError *error))handler{
  return [self RPCToMethod:@"MoveBook"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Book class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
@end
