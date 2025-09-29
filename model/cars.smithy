$version: "2"

namespace ryan.vehicle

/// Provides car valuations.
/// Triple slash comments attach documentation to shapes.
service Vehicle {
    version: "2006-03-01"
    resources: [
        Car
    ]
}

resource Car {
    identifiers: {
        vrm: Vrm
    }
    read: GetCar
}

@readonly
@http(method: "GET", uri: "/cars/{vrm}")
operation GetCar {
    input: GetCarInput
    output: CarInformation
    errors: [
        NoSuchResource
        ValidationException
    ]
}

structure GetCarInput {
    @required
    @httpLabel
    vrm: Vrm
}

/// "pattern" is a trait.
@pattern("^[A-Z]{2}[0-9]{2} ?[A-Z]{3}$")
string Vrm

structure CarInformation {
    @required
    make: String

    model: String

    year: Integer

    price: BigDecimal
}

@error("client")
structure NoSuchResource {
    @required
    resourceType: String
}

@error("client")
structure ValidationException {
    @required
    message: String
}
