// https://bullish.netlify.app/.netlify/functions/subscription
exports.handler = async event => {
  var url = "";

  try {
    const customerId = event.queryStringParameters.id;

    var dev = "sk_test_516YMkSJsg3M9lTqlK4LsbsU0Kv99WcKCPwxyYaZgCJSj47kbddyFxIJTaVoN5PSrlgaYm6jB99vmzzhU7bmHnWNY00bruLuMPw";
    var prod = "";

    const stripe = require("stripe")(dev);

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
