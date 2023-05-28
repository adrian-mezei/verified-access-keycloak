import * as jwt from "jsonwebtoken";

export const handler = async (event: any, context: any): Promise<any> => {
  console.log("event", event);
  console.log("context", context);

  const encodedJwt = event.headers["x-amzn-ava-user-context"];
  const decodedJwt: any = encodedJwt ? jwt.decode(encodedJwt) : "";
  console.log("decodedJwt", decodedJwt);

  return {
    statusCode: 200,
    statusDescription: "200 OK",
    isBase64Encoded: false,
    headers: {
      "Content-Type": "text/html",
    },
    body: `
    <h1>Hello from Lambda!</h1>
      Name: ${decodedJwt?.name}
      <p>
      E-mail: ${decodedJwt?.email}
    `,
  };
};

// when this is started locally
(async () => {
  if (require.main === module) {
    console.log(await handler({}, {}));
  }
})();
