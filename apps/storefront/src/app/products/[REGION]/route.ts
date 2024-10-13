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

export const runtime = "edge";

export async function GET(
  request: NextRequest,
  {
    params,
  }: {
    params: {
      REGION: "US" | "MX";
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
