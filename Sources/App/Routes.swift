import Vapor


final class Routes: RouteCollection {
    func build(_ builder: RouteBuilder) throws {
        

        v1.get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
         }

        v1.get("plaintext") { req in
            return "Hello, world!"
        }
        // response to requests to /info domain
        // with a description of the request
        v1.get("info") { req in
            return req.description
        }
    }
}
/// Since Routes doesn't depend on anything
/// to be initialized, we can conform it to EmptyInitializable
///
/// This will allow it to be passed by type.
extension Routes: EmptyInitializable { }
