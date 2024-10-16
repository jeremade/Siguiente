import { CosmosClient } from "@azure/cosmos";

export const runtime = "edge";

export async function GET() {
  const cosmos = new CosmosClient(process.env.AZURE_COSMOS_KEY!);

  const products = await cosmos
    .database("A")
    .container("Products")
    .items.readAll()
    .fetchAll();

  return Response.json({
    products: products.resources,
  });
}
