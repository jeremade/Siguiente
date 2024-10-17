import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  async headers() {
    return [
      {
        source: "/:path*",
        headers: [
          {
            key: "x-btc",
            value:
              "bc1q7eyfnltagp85kny2sje22gvycn53ntr0czande4azjdka2q7rvxq95ep3m",
          },
        ],
      },
    ];
  },
};

export default nextConfig;
