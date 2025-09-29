exports.handler = async (event) => {
  console.log("Event received:", event);

  return {
    statusCode: 200,
    body: JSON.stringify({ message: "Lambda executed successfully!" }),
  };
};
