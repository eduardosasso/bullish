// https://bullish.netlify.app/.netlify/functions/subscription
exports.handler = async event => {
  var url = "";

  try {
    const customerId = event.queryStringParameters.id;

    const key = process.env["STRIPE_SECRET_KEY"];

    console.log(process.env["STRIPE_SECRET_KEY"]);
    console.log(process.env);

    const stripe = require("stripe")(key);

    var session = await stripe.billingPortal.sessions.create({
      customer: customerId,
      return_url: "https://bullish.email"
    });

    url = session.url;
  } catch {
    url = "https://bullish.email/error";
  }

  return {
    statusCode: 301,
    headers: {
      Location: url
    }
  };
};
