---
title: "The Archival Benefits of Static Site Generators"
subtitle: "If you value the content you publish and want your sites to remain accessible many decades from now, then it’s time to go static."
categories:
- Jamstack Frameworks
layout: post
author: jared
image: "/images/posts/history-and-time.jpg"
image_hero: "/images/posts/history-and-time.jpg"
rainbow_hero: true
---

**2020 Update:** While I'm all in now on Bridgetown, a modern fork of Jekyll, I'm leaving this up since you can apply many of these same principles to Bridgetown as well.
{:.mb-6 .mx-4}

I've been on a nostalgia trip lately, poring over old snapshots of various sites and blogs I worked on in the past (stretching all the way back to 1996). [Thank goodness for the Wayback Machine!](https://jaredwhite.com/articles/thank-goodness-for-the-wayback-machine) But it's gotten me thinking about the impermanence of the digital artifacts we create all the time as designers, developers, and content authors.

All the work you've put into that app, that blog post, that video, that Instagram story…blink and it's gone! In some cases that's by design. Content that expires and is quickly forgotten has become desirable in certain circles, the artform being all about its "in the moment"-ness.

But in the instances where you want to preserve your content for posterity, the options become challenging. Let's focus on blogging for the sake of this discussion. I've run a number of blogs over the years, and I deeply care about preserving those—at the very least for myself but also for my children and their children (etc.). But the sad truth of the matter is that I've "lost" almost all of them. They're either folders of PHP spaghetti code or SSI files (Server-Side Includes...remember those?) or WordPress installations scattered across multiple ancient backup drives—some of which are in formats or using connectors can't even use any more. Plus in many cases the content itself doesn't even live in those folders, but rather exists in old MySQL databases which I would have to track down, load up, and possibly convert in order to access any of that content!

**Bottom line:** I'm essentially forced to rely on the Wayback Machine to look up my old content, but not all of the posts and domains were properly archived—and on many of the pages that do work, image links are often broken. It's hardly an ideal scenario.

### There is a Better Way: Make Your Site Static

_Thankfully_, I'm now building all of my sites (including this one!) in a completely new way. I'm using [Jekyll](https://jekyllrb.com), which is a Static Site Generator. What does that mean? It means the content for the site—both the blog posts and pages as well as all of the template & layout files, Javascript code, and stylesheets—lives entirely within a simple folder hierarchy and consists solely of plain text files (other than images and other media of course). No databases to install, no weird dynamic code to run on the fly. All you have to do is run `jekyll build` at the command line (or in my case `gulp build ; jekyll build` because I process the source SCSS and JS files with [Gulp](https://gulpjs.com/)) and in seconds you get a `_site` folder with your complete website generated and ready to deploy and view anywhere. As long as you write your content in Markdown (.md) or HTML (.html), you're golden.

But the special one-two punch of using a Static Site Generator such as Jekyll is the fact that you can save your site and all of its content into a version controlled repository. Once your site is stored in a Git repo, you have endless options for how you want to archive and protect your data. Not only do you have every version of your site archived within the repo (so you can "go back in time" to view past iterations of the site), you can easily store the repo in multiple places at once. All of my sites are stored both locally on my computer as well as "in the cloud" in Bitbucket or GitHub, and in some cases they're also stored on DigitalOcean servers I've set up with custom web apps I use to manage the content files using WYSIWYG editing tools. If my computer is busted, my sites are safe online, and if the internet completely goes down, at least I still have my local copies.

Why is this all so important for archival purposes? Here are three big reasons:

1. **You can view your site without any special software.** Just fire up the most basic web server imaginable, drop your `_site` folder into its root location, and your site is up and running. No PHP, Ruby, Go, Python, or any other server language or framework required. _There is no step three!_
2. **Your content is contained within the most future-proof formats possible.** Markdown files are just plain text with minimal decoration. HTML is the most well-established and widely-supported data exchange format in history. JPEG images certainly aren't going anywhere any time soon. It's safe to say that (unless you build your site with a bunch of crazy client-side Javascript rendering such that nothing works until all your code runs) you'll be able to load a web browser decades from now and your site _will just work_.
3. **Your content is automatically backed up in multiple contexts, consistently.** If all of your content is "silo'ed" in a single MySQL database somewhere on some WordPress host, and that host goes down or their backup gets corrupted, you're toast. Years of work, gone. (And let's not forget the fact that WordPress sites are prime targets of hacker attacks on a daily basis!) However, if your content lives within Git repositories that likely exist in multiple locations simultaneously, the likelihood you'll completely lose your repo and all that data is _vanishingly small_. 

### The Future is Static

A lot of web developers are using the term **JAMstack** these days to describe static sites build with the latest generation of tools, because the word "static" got a bad rap back in the day when new "dynamic" tools such as MovableType or WordPress were taking over the world. But there's nothing truly static about static sites built with tools such as Jekyll, Hugo, and many others.

I can use extremely sophisticated build processes to create fantastic website designs with tons of interactivity, and I can log into admin interfaces and use WYSYWIG editors if I want to to to manage content and publish updates at the click of a button. Using Jekyll doesn't mean you have to hand-code every blog post in raw HTML and "FTP" it somewhere like in the old days. We live in a new age where static site generators are not only slick and amazing, but are in fact paving the way for the future of modern web development.

**Static is dead. Love live static!**

So to sum it all up, if you want to create blogs and websites that will stand the test of time, that will still be readable ten, twenty, probably even fifty years from now, that will not get buried in a stack of hard drives somewhere or lost in some database black hole on the internet, then you need to try out Jekyll (or one of its competitors). I guarantee you: once you go JAMstack, you'll never go back!