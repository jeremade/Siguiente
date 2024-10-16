import { CosmosClient } from "@azure/cosmos"

export const A = (client: CosmosClient) => client.database("A")

export * from "./products"