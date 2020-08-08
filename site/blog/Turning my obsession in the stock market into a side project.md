# Turning my obsession with the stock market into a side project ⸻
**TL;DR** - Decided to build an automated email newsletter to track the stock market and show pre-market data and historical performance of S&P 500, Nasdaq, and Dow Jones to help with my investments.

The other day I read this [tweet](https://twitter.com/jasonfried/status/1225455247264550917?s=20) from Jason Fried, the founder of [Basecamp](https://basecamp.com), saying that they are working on a new email app called [Hey](Hey.com), and that got me thinking.

Checking my email is one of the first things I do when I wake up, in a quick scan I know if there's something important I should pay attention to, I read the news, and I take the time to keep my inbox tidy. Email is a central tool in my daily workflow.

One thing I like to is to subscribe to email newsletters mostly about tech like [Techmeme](https://techmeme.com/), [Ruby Weekly](https://rubyweekly.com/),  [Hacker News](https://hackernewsletter.com/), [Node Weekly](https://nodeweekly.com/) and news from [WSJ](https://www.wsj.com/newsletters), [Morning Brew](https://www.morningbrew.com/) and [NYT](https://www.nytimes.com/newsletters), I signup to a bunch all the time but I'm very diligent only to keep those I'll read.

Email has a bad rep, spam, clutter. Still, for me, it's such a joy to receive a well-crafted email where people took the time to write something worthwhile and even more time to package that in a beautiful clean design especially in a finicky medium like email with dozens of different clients all rendering things slightly different from one another.

Being stranded at home living the "quarantine" life and with some time in my hands, I thought about building something, and my requirements were:

* It needs to be something I can finish in over a week tops
* Any service I use should be free or freemium 
* Needs to be fully automated, no interventions after it's running 
*  Needs to be something useful to me

Watching the markets tank in March was brutal. The stock market was so volatile that it was hard to keep up with its ups and downs, so my idea was to build something around that.

There are lots of tools to track the market like [screeners](https://www.finviz.com/), tons of finance websites even Google, you can type a ticker name, and it will give you the [stock price and a chart](https://www.google.com/search?sxsrf=ALeKk01r11OmoP895rWnQtnKkZ-QzDfYDA%3A1585421184042&source=hp&ei=gJt_XroZ8rzQ8Q_6ipyYAw&q=voo&btnK=Google+Search).

When you read the news or listen to podcasts about the topic they always talk about when the market open or close in terms of points like the Nasdaq composite closed down 300 points to 7500 or something like that, that's useful for someone in finance or more versed in the markets. Still, to me, all I want to know is how much percentage it gained or loose in a given period like the day before, a week ago, six months ago, and with that, I can tell how the market is trending.

Another thing that I learned some time ago is related to Stock futures, also called pre-market, and that gives you a good indication if the market is trending up or down for the day before it opens for business.

Going back to email and the tweet from Jason Fried, I decided to build an email newsletter with information about the stock markets and data I cared about including:

* Pre-market data for major indexes Nasdaq, S&P 500 e Dow Jones
* Historical performance represented in percentage points

The idea is for the mailing list to go out every weekday before the market opens so you can be informed enough to decide if it's worth paying close attention to the market on any given day and make some moves.

With that in mind, I started with some good old research to figure out what I need to build this thing.

**Needed**
1. API to get stock market futures
2. API that returns historical data for major indexes
3. Email marketing tool with API support
4. Design UI for the newsletter
5. Service to track errors and notify via email
6. A way to schedule and send the emails every day
7. A website so people can sign up
8. Write code to put everything together
9. Ship it 🚀

I've spent the first day or two signing up and playing with finance APIs and email marketing tools until I found one that did what I want and offered a freemium option. I ended up landing on [Sendgrid](https://sendgrid.com/) for email and [Alpha Vantage](https://www.alphavantage.co/) for stock market data.

It’s incredible the amount of work it takes to build even the simplest thing, besides [writing code](https://github.com/eduardosasso/bullish) which is the fun part there are a ton of other tedious admin tasks that need to be done and configured to make everything work like:

* Find a name
* Buy and set up a domain
* Create and redirect email like markets@bullish.email
* Validate email and domain on Sendgrid 
* Setup Google Analytics and Google search console
* Create [Gravatar](https://en.gravatar.com/) and Google account to have a profile pic in the email
* Setup DNS pointing to Github to host the website

Probably finding a name and available domain to register takes the longest in most of my side projects, and it's the first thing I do contrary to what most people would say. I enjoy playing with names, and finding the one that feels right to me gets me psyched and in the right frame of mind to work on the project.

Some of the names I've considered:
* Buy high sell low 
* Buy the dip
* Bull or bear
* Mr. Market

The name that resonated the most with me was **Bullish▲**, I guess because it's timely related to the end of one of the longest US bull markets in history, and I've found the perfect domain available for the small fortune of **$3.88**, and that's how https://bullish.email happened. 

![Promo banner done in guess what? Google slides](/images/bullish.png)

If there's one cool thing about tech nowadays is that pretty much everyone offers a free version of something. You can play with any cloud provider and use it gratis forever as long you are within their free tier. You can publish a site on GitHub for free, including SSL, also free; and a bunch of other stuff. It's awesome!

Anyway, back to the project, after I hooked everything together and spent an awful lot of time designing the email in Sendgrid plus a couple more days writing trash code to test things out and then rewriting it again the proper way, I've finally got to a working version that was up to my standards.

The last thing to do was to decide how to schedule the code to run, prepare, and trigger Sendgrid to send emails every morning.  My first choice was to go [serverless](https://en.wikipedia.org/wiki/Serverless_computing) with [Lambda](https://aws.amazon.com/lambda/) that would fit nicely and wouldn’t cost a dime, but then I realized I have a [Raspberry Pi](https://www.raspberrypi.org/) laying around, so why not use that instead? 

So I've set up the Raspberry Pi to run a [Cron](https://en.wikipedia.org/wiki/Cron) job every day around 9:00 AM eastern time, which is 30 minutes before the market opens and I’ve also used https://cronhub.io to monitor the job and alert me if it doesn't run, and that was it. A little over a week's worth of work and that nice runner's high kind of feeling of getting another project across the finish line.

![This is how the email looks like](/images/screenshot.png)

If you want to give it a try, you can signup to get **[Bullish▲](https://bullish.email)** in your inbox every morning at https://bullish.email; you can also check out the code on [Github](https://github.com/eduardosasso/bullish/).

Stay healthy. Cheers ~
