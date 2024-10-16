import { CosmosClient } from "@azure/cosmos";
import { type NextRequest } from "next/server";

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
  const cosmos = new CosmosClient(process.env.AZURE_COSMOS_KEY!);
  const product = await cosmos
    .database("A")
    .container("Products")
    .item(params.ID, params.CATEGORY)
    .read();

  return Response.json(product.resource);
}
