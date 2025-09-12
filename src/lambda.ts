import {
  APIGatewayProxyEvent,
  APIGatewayProxyResult,
  Context,
} from "aws-lambda";
import { VehicleService } from "../build/smithy/source/typescript-server-codegen/src/server/VehicleService";
import { GetCarServerInput } from "../build/smithy/source/typescript-server-codegen/src/server/operations/GetCar";
import {
  CarInformation,
  NoSuchResource,
} from "../build/smithy/source/typescript-server-codegen/src/models/models_0";
import { lookupCarByVrm } from "./carRepository";

const vehicleService: VehicleService<{}> = {
  GetCar: async (input: GetCarServerInput): Promise<CarInformation> => {
    const { vrm } = input;

    const car = await lookupCarByVrm(vrm!);

    if (!car) {
      throw new NoSuchResource({
        resourceType: "Car",
        message: `No car found with VRM: ${vrm}`,
      });
    }

    return car;
  },
};

export const handler = async (event: APIGatewayProxyEvent, context: Context): Promise<APIGatewayProxyResult> => {
  const vrm = event.pathParameters?.vrm;
  if (!vrm) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: "VRM parameter is required" }),
    };
  }

  const result = await vehicleService.GetCar({ vrm }, context);

  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(result),
  };
};
