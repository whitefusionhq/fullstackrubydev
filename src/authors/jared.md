---
layout: page
title: Articles by Jared
---

# Latest Articles
{: .mb-6 .title .has-text-centered}

{% assign posts = site.posts | slice: 0, 4 %}
{% render "bulmatown/collection", collection: posts, metadata: site.metadata %}

{% if site.posts.size > 6 %}
  <a href="/articles" class="button is-primary is-outlined is-small"><span>Previous Articles</span> <span class="icon"><i class="fa fa-arrow-right"></i></span></a>
  {: .mt-6 .has-text-centered}
{% endif %}
