import { CosmosClient } from "@azure/cosmos";
import { NextRequest } from "next/server";

function cosmosdbkey(region: string) {
  return process.env["COSMOS_" + region]!;
}

export const runtime = "edge";

export async function GET(
  _request: NextRequest,
  {
    params,
  }: {
    params: {
      REGION: string;
    };
  }
) {
  const cosmos = new CosmosClient(cosmosdbkey(params.REGION));
  const products = await cosmos
    .database("SampleDB")
    .container("SampleContainer")
    .items.readAll()
    .fetchAll();

  return Response.json({
    products: products.resources,
  });
}
