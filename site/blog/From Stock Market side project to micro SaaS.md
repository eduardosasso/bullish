# From stock market side project to micro SaaS
---
A couple of months back, during this crazy world pandemic, I had an idea for a [Stock Market email newsletter](https://bullish.email). 

Nothing novel, the initial premise was to build a fully automated hands-off email with some key stats I care about and send it every weekday before the markets open, and that's how https://bullish.email came to be.

Doing rounds trying to promote my little pet project, I posted it on [Hacker News](https://news.ycombinator.com/item?id=22870667) and received great feedback, and one thousand people were convinced enough to subscribe.

That initial traction, combined with all the positive comments and suggestions, was the signal I needed to upgrade from side hustle to tiny micro SaaS indie venture.

I planned to offer a premium version of the newsletter with a lot more data points and insights and charge money for it. Plain and simple.

But to do that, I had to do a good amount of code refactoring, hookup Stripe, update the website, make all the plumbing work, and promote it.

And that's where the fun begins again. Let's get to work!

The first thing I tackled was to [build new data points](https://github.com/eduardosasso/bullish/tree/master/services), all of them based on variations of the unofficial [Yahoo Finance API](https://github.com/eduardosasso/bullish/blob/master/services/config.rb).

From those API's I've extracted insights like
* Performance by sector
* Trending stocks
* Top gainers and losers
* All-time high stats
* Crypto performance

There's a lot you can do with Yahoo's API. 

For each of those data points, I formatted their results with an emphasis on percentage performance to keep it consistent with the original version of Bullish and maintain its uniqueness.

Next, I had to find a way to design and easily code email layouts. Creating email templates is a huge pain. You have to inline CSS everywhere, nothing works, and every change is a pain and hard to reuse. There's gotta be a better way.

After some research, I found  [MJML](https://mjml.io/) , which is essentially a markup layer on top of HTML built for designing responsive emails. It works great, no more writing arcane HTML and fighting email client compatibility.

My mental model for Bullish Pro centered around the concept [editions](https://github.com/eduardosasso/bullish/tree/master/editions), and that translated to a [free edition](https://github.com/eduardosasso/bullish/blob/master/editions/free.rb), a [morning edition](https://github.com/eduardosasso/bullish/blob/master/editions/morning.rb), and an [afternoon edition](https://github.com/eduardosasso/bullish/blob/master/editions/afternoon.rb) for paid subscribers.

Editions are composed of [elements or widgets](https://github.com/eduardosasso/bullish/blob/master/editions/widgets.rb) and change daily, like a newspaper. Between Monday and Friday, each edition includes a set of widgets reused interchangeably to create the final email layout.

This notion of daily editions combined with elements gives a lot of versatility when creating layouts.

![Different elements combined](./email1.png)
![Different elements combined](./email2.png)
![Other variations](./email3.png)
![Other variations](./email4.png)

Each element gets hooked up to a data point, so for trending stocks, you can expect to have a widget to render that, same thing for pre-market futures, crypto, etc.

Elements use the [Mustache](http://mustache.github.io/) template engine to take variables and replace them with data and do some formatting like green or red if the value is positive or negative.

With this design, it's easy to add new components and move them around to create unique [templates](https://github.com/eduardosasso/bullish/blob/master/templates/template.rb) with almost zero code.

Editions have a tag specifying their group ID, so emails go out to the right group free or premium.

Of course, there's a lot of plumbing involved in stitching everything together like compressing emails to be [under 102k](https://mailchimp.com/help/gmail-is-clipping-my-email/), so they don't break in Gmail and things like that, but that's a good overview of how I revamped Bullish to support different email formats without giving away the idea of full automation.

The infrastructure is still pretty much the same, three CRON jobs set up in a Raspberry PI to create the HTML of each edition and calls to [MailerLite](https://www.mailerlite.com/) API to schedule distribution. Check the [previous article](https://eduardosasso.co/blog/turning-my-obsession-in-the-stock-market-into-a-side-project/) for more details.

For payments, I used Stripe and their drop-in [checkout flow](https://stripe.com/docs/payments/checkout) to accept payments and [Stripe Billing](https://stripe.com/billing) for managing recurring subscriptions connected to a few [Zapier](https://zapier.com/) recipes to handle users moving from free group to premium and downgrading from premium back to free when they cancel.

With Stripe Billing and a sprinkle of Javascript [cloud function](https://www.netlify.com/products/functions/) deployed to [Netlify](https://www.netlify.com), I've set up a magic link on premium emails, so paid users can update or cancel their subscriptions directly in Stripe securely.

Based on the customer id, Stripe generates a unique link on demand so users can update their subscription without having to log in or create an account, it's zero friction.

Leveraging Zapier was a big time saver, and it's less code I need to write and maintain. They offer a free plan that includes five zaps, and that's what I use.

Another huge time saver was moving the website over to Netlify. They have such an excellent product with killer features like branch previews for testing, automatic asset compression, and serverless functions that are ridiculously easy to use with no config whatsoever write Javascript and deploy plus a generous free tier.

[Stripe](https://stripe.com) is also another great product. From documentation to testing and configuration and support for Apple and Google pay, everything was a joy to use and simple to integrate into the flow I had in mind and seamless to users—big fan.

I let this setup run for a few days to make sure everything worked as expected before I made my first move into upselling the premium version.

Time to sell. 

My initial strategy was to convert existing subscribers first before going out to the world.

So I crafted an email in a personal tone, where the subject was "[It's launch day!](https://preview.mailerlite.com/o2y8k1)". In this email, I started by giving an overview where Bullish was at and then introducing Bullish Premium for 4.99/mo along with all the features we were releasing and a big green call to action button saying, "**Subscribe now**."

My honest expectation was to get maybe four or five users to convert, but we end up closing ten on the first day. We celebrated with Sushi!

That got us to an instant **$50 monthly recurring revenue!** Almost ramen profitability.

The numbers are so small, but you've got to start somewhere. I've done lots of side projects over the years, and they all brought me some indirect form of monetization. It was through a side project that I ended up in Silicon Valley, but this is the first time I'm directly selling things to people.

After some validation from the first sales, I moved on to the next big topic in my todo—a new website.

I've put together the first version of the website in a couple of hours using my yet-to-be-released static site generator called [Leter](https://github.com/eduardosasso/leter), which also powers this article by the way.


![First version](./first_site.png)

It was Ok but far from what I had in mind, but I had to ship something, so I pushed a professional better-looking website for later.

I know my weaknesses, and web design is a time sink for me. I'm very opinionated, and I like to think I have a good eye for it, but so far, I couldn't deliver anything I was proud of on my own.

After learning from my fail attempts over the years trying to come up with an exclusive design this time around, I looked for references, inspiration, and templates that could help me jump-start the process.

As an engineer, I always feel inclined to start everything from scratch, and with the new website was no different, the utopian dream of the perfect, valid HTML and clean CSS a trap that I fell into way too many times but not again.

I ended up [finding a template](https://themeforest.net/item/fold-software-and-app-template/24295615) that was pretty close to what I had in mind. I just had to brush off my CSS skills and do some customization to take my vision to reality.

Of course, I have a list of things to improve like adding archives or a way to update the sample email dynamically, but overall I'm pretty happy how it turned out.


![New version](./new_site.png)

With the site up and running, it was time to promote it.

Before trying the big leagues on [Product Hunt](https://www.producthunt.com), we tested the waters by engaging on Twitter and getting a few subscribers. Then, I asked my [influencer brother](https://www.linkedin.com/in/abduzeedo/) to post on his [LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:6693739953026945024/), which generated a nice amount of traffic and about fifty new readers, not hockey stick growth but decent. 

For [Product Hunt](https://www.producthunt.com/posts/bullish), we scheduled our launch for a Wednesday, and I remember going to sleep that night, excited to see what the next day would bring, and we bombed, we never made to the frontpage and only got like 20 upvotes it was a total disaster.

The next day was business as usual, a little bruised, maybe, but that's how things go, I guess it will take a few more years to be an overnight success. 

Fast forward to Sunday morning. Things are back to normal, I'm having pancakes for breakfast, and I start seeing this uptick in subscribers out of the blue.

So it turns out [Product Hunt featured us](https://www.producthunt.com/posts/bullish) in their Sunday edition, and we were on the front page the whole day, gaining around 200 new subscribers. What a comeback!

All and all, Bullish has been a welcome surprise in my life. I'm happy about the consistency to which I can work on it almost every night and a few weekends and how having constraints helps you narrow your focus, and it compounds beautifully.

Lots more to come.

Give [Bullish▲](https://bullish.email) a try!

Cheers.
