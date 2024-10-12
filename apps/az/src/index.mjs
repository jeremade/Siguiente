import { app } from "@azure/functions";

app.setup({
  enableHttpStream: true,
});

app.http("eventHubTrigger1", {
  async handler() {
    return Response.json({
      data: ["hola"],
    });
  },
});
