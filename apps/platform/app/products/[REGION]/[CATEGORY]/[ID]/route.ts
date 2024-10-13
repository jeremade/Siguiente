import { CosmosClient } from "@azure/cosmos";
import { NextRequest } from "next/server";

function cosmosdbkey(region: string) {
  return process.env["COSMOS_" + region]!;
}

export async function GET(
  _request: NextRequest,
  {
    params,
  }: {
    params: {
      REGION: string;
      CATEGORY: string;
      ID: string;
    };
  }
) {
  const cosmos = new CosmosClient(cosmosdbkey(params.REGION));
  const product = await cosmos
    .database("SampleDB")
    .container("SampleContainer")
    .item(params.ID, params.CATEGORY)
    .read();

  return Response.json(product.resource);
}
