import { Container, Database } from "@azure/cosmos";
import { pipe } from "lodash/fp";

export const Products = (db: Database) => db.container("Products");

export const ProductItems = pipe(Products, (c: Container) => {
  return c.items.readAll().getAsyncIterator();
});
