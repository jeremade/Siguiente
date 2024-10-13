import { CosmosClient } from "@azure/cosmos";
import { NextRequest } from "next/server";

interface Tag {
  id: string;
  name: string;
}

interface Product {
  id: string;
  categoryId: string;
  categoryName: string;
  sku: string;
  name: string;
  description: string;
  price: number;
  tags: Tag[];
}

function cosmosdbkey(region: "US" | "MX") {
  return process.env["COSMOS_" + region]!;
}

export async function GET(
  request: NextRequest,
  {
    params,
  }: {
    params: {
      REGION: "US" | "MX";
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
