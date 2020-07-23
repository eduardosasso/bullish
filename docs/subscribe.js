exports.handler = async event => {
  const key = process.env["MAILERLITE_API_KEY"];
  const request = require("axios");

  const Sentry = require("@sentry/node");

  Sentry.init({
    dsn: process.env["SENTRY_DSN"]
  });

  try {
    const body = JSON.parse(event.body);

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

    let response = await request(options);

    console.info(response.data)

    return {
      statusCode: 200,
      body: "You're in! Check your email for confirmation."
    };

    console.info(response.data);
  } catch (error) {
    console.log(error.response);

    Sentry.captureException(error);
    await Sentry.flush(2000);

    return {
      statusCode: 500,
      body: "Sorry. Something went wrong."
    };
  }
};
