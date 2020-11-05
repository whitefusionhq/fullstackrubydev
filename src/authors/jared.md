---
layout: page
title: Articles by Jared
template_engine: liquid
---

Hi, I'm Jared! I help maintain Ruby open source software like [Bridgetown](https://www.bridgetownrb.com) and [Ruby2JS](https://github.com/rubys/ruby2js), and I work as a consultant with [Whitefusion](https://whitefusion.io). **RUBY3.dev** is my pet project. ☺ Find me on Twitter [@jaredcwhite](https://twitter.com/jaredcwhite){:rel="noopener"}.
{: .has-text-centered}

----
  
# Latest Articles
{: .mb-6 .title .has-text-centered}

{% assign posts = site.posts | slice: 0, 4 %}
{% render "bulmatown/collection", collection: posts, metadata: site.metadata %}

{% if site.posts.size > 6 %}
  <a href="/articles" class="button is-primary is-outlined is-small"><span>Previous Articles</span> <span class="icon"><i class="fa fa-arrow-right"></i></span></a>
  {: .mt-6 .has-text-centered}
{% endif %}
