---
title: "Jekyll’s Hidden Depths"
subtitle: "As anyone who has used Jekyll for a while knows, it's capable of so much more than first meets the eye. Here are a few tricks I discovered while redesigning my personal website."
categories:
- Jamstack Frameworks
layout: post
author: jared
image: "/images/posts/depths.jpg"
image_hero: "/images/posts/depths.jpg"
---

**2020 Update:** While I'm all in now on Bridgetown, a modern fork of Jekyll, I'm leaving this up since you can apply many of these same principles to Bridgetown as well.
{:.mb-6 .mx-4}

As part of a large redesign of my personal website and blog at [jaredwhite.com](https://jaredwhite.com), I was able to put Jekyll through its paces in some interesting ways. The following is a collection of three nifty Jekyll techniques you might not have heard about before. (At least I hadn't…these all came about through copious trial and error. My pain is your gain!)

### Organize Your Posts Folder

The default way you add a new post to a Jekyll blog is to create a new file in the `_posts` folder, typically with a date at the beginning such as `2018-05-13-a-blog-post.md`.

But for my new website, I wanted to be able to distinguish between different post types. For example, I've organized my content around four types: **Thoughts**, **Pictures**, **Links**, and **Articles**. Having those all taking up space in a single folder would make it very hard to navigate over time. In addition, I have posts going back years (older blog content had been imported into Jekyll previously), so I wanted to avoid having a folder with many hundreds of files in it.

So the first thing I did was create separate folders under `_posts` for the four types. I ended up with:

* `_posts/thoughts`
* `_posts/pictures`
* `_posts/links`
* `_posts/articles`

The next step was to collect all content in a given year into a folder just for that year. The result was a series of descriptive folder hierarchies such as `_posts/pictures/2018` or `_posts/articles/2014`.

Now it's important to remember that Jekyll doesn't add any special metadata to posts in subfolders of `_posts`. So just putting something in `pictures` doesn't ensure that post will go into the `pictures` category. You still have to add `categories: pictures` to the front matter of the post. _However_, there is one mechanism to put posts into categories automatically: you can create a top-level folder inside your Jekyll repo and put a `_posts` folder into _that_. In other words, it would be something like `pictures/_posts`, etc.

I've done that sort of thing in the past and ended up not liking it. I really don't like cluttering up my top-level Jekyll folder any more than I have to. I prefer the mental model of having everything organized inside of a single `_posts` folder. So I've chosen the manual route as far as category front matter is concerned. (And to be honest, I'm using a custom Rails-based content editing system I've built for myself which populates the front matter for each content type automatically. So it's pretty straightforward.)

I definitely love having year subfolders for posts and will now start doing that on all my blogs in the future. Organizing hierarchically by some meaningful criteria such as category/post-type is a useful option for larger sites that might have hundreds or thousands of posts.

### Format Post Types with Includes

It's common in Jekyll setups to have a `post.html` layout file which renders a blog post and an `index.html` or `blog.html` page which loops through blog posts and renders excerpts (or maybe the full post text).

In the case of my new website, because of the "social media" styling that the content and visual design is oriented around, I knew that I'd want a **Thought** post or **Picture** post or **Link** post to look the same everywhere—on the homepage, on a single post page, or in archives (such as hashtag pages…more on that below). The only exception is an **Article** post. Those display as excerpts in all contexts except the actual post page, in which case the full article is rendered as long-form content.

To make matters even more complicated, I also wanted to control how different post types would render out in RSS/JSON feeds. Not only that, I use Jekyll to build the HTML for my email newsletters (each newsletter is a compilation of the most recent posts on the site), so I would need to control how post types render for the special (aka goofy and weird) markup required for the email campaigns.

So I decided to use _partials_ to define the markup for all my post types. Because of the various contexts mentioned above, I ended up with _three_ different folders under the `_includes` folder:

* `_includes/post_types`
* `_includes/feed_post_types`
* `_includes/newsletter_post_types`

And in each of those folders, I have four files:

* `thought.html`
* `picture.html`
* `link.html`
* `article.html`

Then in various template files in various contexts, I'm able to include the relevant post type partials as required. For example, in my feed templates:

{% raw %}
```html
{% for post in site.posts limit:20 %}
  {% capture page_content %}
    {% if post.category == 'thoughts' %}
      {% include feed_post_types/thought.html post=post %}
    {% elsif post.category == 'pictures' %}
      {% include feed_post_types/picture.html post=post %}
    {% elsif post.category == 'links' %}
      {% include feed_post_types/link.html post=post %}
    {% else %}
      {% include feed_post_types/article.html post=post %}
    {% endif %}
  {% endcapture %}
  <item>
    ...
    <description>{{ page_content | xml_escape }}</description>
  </item>
{% endfor %}
```
{% endraw %}

A common programming refrain is DRY (Don't Repeat Yourself). Using partials to define post markup only once, and then including those in various contexts across the whole site is a great way to imbue your Jekyll build with DRY principles.

### Jazz Up Your Posts with Hashtags

_The following technique isn't supported if you host your Jekyll blog with GitHub pages. I highly recommend using a hosting provider such as [Netlify](https://www.netlify.com) which allows you to use any custom plugin (and many other highly-advanced workflows) for your Jekyll deployments. Bonus: for the majority of smaller-scale projects, it's free!_

One of the ways I make my website feel more like modern social media is the use of hashtags. If I post a picture of bridge in Portland, I want to be able to add **\#portland** as a hashtag in the caption. This requires two interrelated pieces of functionality to be in place: (a) the ability for the hashtag to link to an archive page with all similarly-tagged content, and (b) the ability for posts to be tagged in the first place.

Tags as a concept for Jekyll posts is nothing new. [`jekyll-tagging`](https://github.com/pattex/jekyll-tagging) is a popular gem and the one I used to solve (b). So for the front matter of a post that has one or more hashtags, it's very simple to specify them like so:

`tags: Facebook openweb`

The `jekyll-tagging` plugin then handles creating an archive for the `Facebook` tag, the `openweb` tag, etc., and making sure the post ends up in those archives. _However_, what it doesn't do is convert the actual **\#Facebook** or **\#openweb** text to working links that point to those tag archives. To solve (a), I had to write my own custom plugin that would provide a special Liquid filter (`/_plugins/hashtags.rb`):

```ruby
module Jekyll
  module HashtagsFilter
    def hashtags(input)
      tag_url_prefix = @context.registers[:site].config["url"].to_s + "/tag/"      
      input.gsub(/(^|\s|\>)#([a-z\d-]+)/i, "\\1<a href=\"#{tag_url_prefix}\\2\" class=\"hashtag\">#\\2</a>")
    end
  end
end

Liquid::Template.register_filter(Jekyll::HashtagsFilter)
```

And that's it! Now all I need to do is use the `hashtags` filter wherever I display content that needs those special links. For example:

{% raw %}`{{ include.post.content | hashtags }}`{% endraw %}

It's perhaps not ideal that you have to put a **\#hashtag** in the body of a post as well as include the tag in the front matter. But what follows is no surprise: my custom editing system actually scans a post's content for hashtags and adds them to the front matter automatically. It's pretty great.

### Jekyll: You can run but you can't Hyde

Jekyll is an amazingly powerful content system right out of the box. But with a few added plugins or creative uses of existing features, it can do almost anything imaginable. I've built a wide variety of websites on top of Jekyll over the last couple of years and I still feel like I'm learning new tricks every day.

I hope you found this article helpful! Got any questions about Jekyll? [Please direct them my way](mailto:jared@jaredwhite.com) (plus sign up to get notified about future posts).

