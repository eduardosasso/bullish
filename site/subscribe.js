exports.handler = async event => {
  const key = process.env["MAILERLITE_API_KEY"];
  const request = require("axios");

  const Sentry = require("@sentry/node");

  Sentry.init({
    dsn: process.env["SENTRY_DSN"]
  });

  const body = JSON.parse(event.body);

  try {
    const options = {
      method: "POST",
      url: "https://api.mailerlite.com/api/v2/subscribers",
      data: {
        email: body.email
      },
      headers: {
        "Content-Type": "application/json",
        "x-mailerlite-apikey": key
      }
    };

    // create subscriber
    await request(options);

    // free group
    // const groupUrl = "https://api.mailerlite.com/api/v2/groups/102872974/subscribers";

    // premium trial
    const groupUrl = "https://api.mailerlite.com/api/v2/groups/105236984/subscribers";

    options.url = groupUrl;

    await request(options);

    console.info("SUCCESS: " + body.email);

    return {
      statusCode: 200
    };

  } catch (error) {
    console.error(body.email);

    Sentry.captureException(error);
    await Sentry.flush(2000);

    return {
      statusCode: 500
    };
  }
};
