exports.handler = async event => {
  const key = process.env["MAILERLITE_KEY"];
  const request = require("request");
  const email = event.queryStringParameters.email;

  const options = {
    url: "https://api.mailerlite.com/api/v2/subscribers",
    json: true,
    body: {
      email: email
    },
    headers: {
      "Content-Type": "application/json",
      "x-mailerlite-apikey": key
    }
  };

  request.post(options, (err, res, body) => {
    if (err) {
      return console.log(err);
    }
    console.log(body);
  });
};
