---
layout: page
title: Articles by Jared
---

Hi, I'm Jared! I help maintain Ruby open source software like [Bridgetown](https://www.bridgetownrb.com) and [Ruby2JS](https://github.com/rubys/ruby2js), and I work as a consultant with [Whitefusion](https://www.whitefusion.studio). **Fullstack Ruby** is my pet project. ☺ Find me on Mastodon [@jaredwhite@indieweb.social](https://indieweb.social/@jaredwhite){:rel="noopener"}.
{: .has-text-centered}

----
  
# Latest Articles
{: .mb-6 .title .has-text-centered}

{% posts = collections.posts.resources[0...4] %}
{%= liquid_render "bulmatown/collection", collection: posts, metadata: site.metadata %}

{% if collections.posts.resources.size > 4 %}
  <a href="/articles" class="button is-primary is-outlined is-small"><span>Previous Articles</span> <span class="icon"><i class="fa fa-arrow-right"></i></span></a>
  {: .mt-6 .has-text-centered}
{% end %}
