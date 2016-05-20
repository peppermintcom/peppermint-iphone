#import "google/example/library/v1/Library.pbobjc.h"

#import <ProtoRPC/ProtoService.h>
#import <RxLibrary/GRXWriteable.h>
#import <RxLibrary/GRXWriter.h>

#import "google/api/Annotations.pbobjc.h"
#import "google/protobuf/Empty.pbobjc.h"

@protocol LibraryService <NSObject>

#pragma mark CreateShelf(CreateShelfRequest) returns (Shelf)

- (void)createShelfWithRequest:(CreateShelfRequest *)request handler:(void(^)(Shelf *response, NSError *error))handler;

- (ProtoRPC *)RPCToCreateShelfWithRequest:(CreateShelfRequest *)request handler:(void(^)(Shelf *response, NSError *error))handler;


#pragma mark GetShelf(GetShelfRequest) returns (Shelf)

- (void)getShelfWithRequest:(GetShelfRequest *)request handler:(void(^)(Shelf *response, NSError *error))handler;

- (ProtoRPC *)RPCToGetShelfWithRequest:(GetShelfRequest *)request handler:(void(^)(Shelf *response, NSError *error))handler;


#pragma mark ListShelves(ListShelvesRequest) returns (ListShelvesResponse)

- (void)listShelvesWithRequest:(ListShelvesRequest *)request handler:(void(^)(ListShelvesResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToListShelvesWithRequest:(ListShelvesRequest *)request handler:(void(^)(ListShelvesResponse *response, NSError *error))handler;


#pragma mark DeleteShelf(DeleteShelfRequest) returns (Empty)

- (void)deleteShelfWithRequest:(DeleteShelfRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler;

- (ProtoRPC *)RPCToDeleteShelfWithRequest:(DeleteShelfRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler;


#pragma mark MergeShelves(MergeShelvesRequest) returns (Shelf)

- (void)mergeShelvesWithRequest:(MergeShelvesRequest *)request handler:(void(^)(Shelf *response, NSError *error))handler;

- (ProtoRPC *)RPCToMergeShelvesWithRequest:(MergeShelvesRequest *)request handler:(void(^)(Shelf *response, NSError *error))handler;


#pragma mark CreateBook(CreateBookRequest) returns (Book)

- (void)createBookWithRequest:(CreateBookRequest *)request handler:(void(^)(Book *response, NSError *error))handler;

- (ProtoRPC *)RPCToCreateBookWithRequest:(CreateBookRequest *)request handler:(void(^)(Book *response, NSError *error))handler;


#pragma mark GetBook(GetBookRequest) returns (Book)

- (void)getBookWithRequest:(GetBookRequest *)request handler:(void(^)(Book *response, NSError *error))handler;

- (ProtoRPC *)RPCToGetBookWithRequest:(GetBookRequest *)request handler:(void(^)(Book *response, NSError *error))handler;


#pragma mark ListBooks(ListBooksRequest) returns (ListBooksResponse)

- (void)listBooksWithRequest:(ListBooksRequest *)request handler:(void(^)(ListBooksResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToListBooksWithRequest:(ListBooksRequest *)request handler:(void(^)(ListBooksResponse *response, NSError *error))handler;


#pragma mark DeleteBook(DeleteBookRequest) returns (Empty)

- (void)deleteBookWithRequest:(DeleteBookRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler;

- (ProtoRPC *)RPCToDeleteBookWithRequest:(DeleteBookRequest *)request handler:(void(^)(GPBEmpty *response, NSError *error))handler;


#pragma mark UpdateBook(UpdateBookRequest) returns (Book)

- (void)updateBookWithRequest:(UpdateBookRequest *)request handler:(void(^)(Book *response, NSError *error))handler;

- (ProtoRPC *)RPCToUpdateBookWithRequest:(UpdateBookRequest *)request handler:(void(^)(Book *response, NSError *error))handler;


#pragma mark MoveBook(MoveBookRequest) returns (Book)

- (void)moveBookWithRequest:(MoveBookRequest *)request handler:(void(^)(Book *response, NSError *error))handler;

- (ProtoRPC *)RPCToMoveBookWithRequest:(MoveBookRequest *)request handler:(void(^)(Book *response, NSError *error))handler;


@end

// Basic service implementation, over gRPC, that only does marshalling and parsing.
@interface LibraryService : ProtoService<LibraryService>
- (instancetype)initWithHost:(NSString *)host NS_DESIGNATED_INITIALIZER;
+ (instancetype)serviceWithHost:(NSString *)host;
@end
