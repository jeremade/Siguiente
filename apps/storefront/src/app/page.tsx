import { FetchProducts } from "./fetchProducts";

export const metadata = {
  title: "Store | Kitchen Sink",
};

export default function Store(): JSX.Element {
  return (
    <div className="container">
      <FetchProducts />
    </div>
  );
}
