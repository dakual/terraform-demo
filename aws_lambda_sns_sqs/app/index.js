exports.handler = function (event, context) {
  console.log("EVENT\n" + JSON.stringify(event))
  return {success: true}
};