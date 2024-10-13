"use server";

import { CosmosClient } from "@azure/cosmos";

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

export async function getProducts() {
  const cosmos = new CosmosClient(cosmosdbkey("US"));
  const products = await cosmos
    .database("SampleDB")
    .container("SampleContainer")
    .items.readAll<Product>()
    .fetchAll();

  return products.resources;
}
