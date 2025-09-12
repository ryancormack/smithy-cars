import { CarInformation } from "../build/smithy/source/typescript-server-codegen/src/models/models_0";

export const lookupCarByVrm = async (vrm: string) => {
    const mockCars: Record<string, CarInformation> = {
          AB12CDE: {
            make: "Toyota",
            model: "Camry",
            year: 2020,
            price: {
              type: "bigDecimal",
              string: "25000.00",
            },
          },
          XY98ZAB: {
            make: "Honda",
            model: "Civic",
            year: 2019,
            price: {
              type: "bigDecimal",
              string: "22000.00",
            },
          },
        };

    return mockCars[vrm.toUpperCase() || ""] || null;
    }