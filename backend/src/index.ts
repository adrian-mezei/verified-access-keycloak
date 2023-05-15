export const handler = async (event: any, context: any): Promise<any> => {
  console.log("event", event);
  console.log("context", context);
  return { statusCode: 200 };
};
