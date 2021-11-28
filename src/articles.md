---
layout: page
title: Articles
exclude_from_search: true
paginate:
  collection: posts
---

{% posts = paginator.resources %}
{%= liquid_render "bulmatown/collection", collection: posts, metadata: site.metadata %}

{%= liquid_render "bulmatown/pagination", paginator: paginator %}