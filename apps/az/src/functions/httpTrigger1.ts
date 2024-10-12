import { app } from "@azure/functions";

app.http("eventHubTrigger1", {
  async handler() {
    return Response.json({
      data: ["hola"]
    })
  }
});
