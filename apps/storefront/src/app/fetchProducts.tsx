"use client";

import { useFormState } from "react-dom";
import { getProducts } from "./actions";

export function FetchProducts() {
  const [products, formAction, isPending] = useFormState(getProducts, []);

  return (
    <form action={formAction}>
      {Boolean(products.length) && (
        <ol>
          {products.map((product) => (
            <li key={product.id}>
              {product.name} ({product.price})
            </li>
          ))}
        </ol>
      )}
      <button disabled={isPending} type="submit">
        {isPending ? <>Loading...</> : <>Get Products</>}
      </button>
    </form>
  );
}
