import * as jwt from "jsonwebtoken";

export const handler = async (event: any, context: any): Promise<any> => {
  console.log("event", event);
  console.log("context", context);

  // const encodedJwt = event.headers["x-amzn-ava-user-context"];
  const encodedJwt =
    "eyJ0eXAiOiJKV1QiLCJraWQiOiI3YmY0MzkxOC0zMGJkLTQ1ZTgtOTA4Yy1lMmU5ZWFhYzE1ODciLCJhbGciOiJFUzM4NCIsImlzcyI6Imh0dHBzOi8va2V5Y2xvYWsuc2VydmVybGVzcy1idWRhcGVzdC5jb20vcmVhbG1zL21hc3RlciIsImNsaWVudCI6ImF3cy12ZXJpZmllZC1hY2Nlc3MtYXBwbGljYXRpb24iLCJzaWduZXIiOiJhcm46YXdzOmVjMjpldS1jZW50cmFsLTE6NDg0MzE1OTYzNzc0OnZlcmlmaWVkLWFjY2Vzcy1pbnN0YW5jZS92YWktMDQ2ZmUzZTg1Mjk0YzBhM2YiLCJleHAiOjE2ODQ1OTAxMjZ9.eyJzdWIiOiIwM2YxYmRiOS00M2VlLTQ0ODEtOWIwMi05MzE2MzNkNTIzNWQiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwibmFtZSI6Ik1hbmFnZXIgTWFyaW8iLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJtYW5hZ2VyX21hcmlvIiwiZ2l2ZW5fbmFtZSI6Ik1hbmFnZXIiLCJmYW1pbHlfbmFtZSI6Ik1hcmlvIiwiZW1haWwiOiJtYW5hZ2VyLm1hcmlvQHNlcnZlcmxlc3MtYnVkYXBlc3QuY29tIiwiZXhwIjoxNjg0NTkwMTI2LCJpc3MiOiJodHRwczovL2tleWNsb2FrLnNlcnZlcmxlc3MtYnVkYXBlc3QuY29tL3JlYWxtcy9tYXN0ZXIifQ.4PfKeXMp_T_ubDxeyatYHIi2HMUTPG6_zFKK2Wm_qpBOIK4pYxMhoCXHccYuMfOHk1aPYEtDAmiNGMJOZRUa41Vz8w-vm6dyQrFiCKMunfel90T24szj2iP8qZkPqBom";
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
