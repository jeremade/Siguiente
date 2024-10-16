import { CosmosClient } from "@azure/cosmos";
import { always, invoke, pipe } from "lodash/fp";
import ponyfill from "@edge-runtime/ponyfill";
import Z from "zod";
import { A, Products } from "./demo"

const cosmosEnv = Z.object({
  AZURE_COSMOS_KEY: Z.string().readonly(),
});

export const connectionString = always(cosmosEnv.parse(process.env).AZURE_COSMOS_KEY);
export const DB = () => new CosmosClient(connectionString());

function masterKey() {
  return new ponyfill.TextEncoder().encode(
    cosmosEnv.parse(process.env).AZURE_COSMOS_KEY
  );
}

export async function createClientToken(
  verb: "GET" | "POST" | "PATCH",
  resourceId: string,
  resourceType: string = "dbs"
) {
  const request =
    (verb || "").toLowerCase() +
    "\n" +
    (resourceType || "").toLowerCase() +
    "\n" +
    (resourceId || "") +
    "\n" +
    new Date().getDate().toString() +
    "\n" +
    "" +
    "\n";

  const k = await ponyfill.crypto.subtle.importKey(
    "raw",
    masterKey(),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const signature = await ponyfill.crypto.subtle
    .sign("HMAC", k, new ponyfill.TextEncoder().encode(request))
    .then(Buffer.from);

  const MasterToken = "master";

  const TokenVersion = "1.0";

  return encodeURIComponent(
    "type=" + MasterToken + "&ver=" + TokenVersion + "&sig=" + signature
  );
}

export * from "./demo"
export * from "./demo/products"