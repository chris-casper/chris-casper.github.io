---
title: "Spy Museum"
excerpt: "Largest collection of espionage artifacts in the world"
tags:
  - gallery
location:
    latitude: 
    longitude: 
header:
  image: /assets/images/SpyMuseum-header-01.jpg
  teaser: /assets/images/SpyMuseum-teaser-01-th.jpg
sidebar:
  - title: "Role"
    image: http://placehold.it/350x250
    image_alt: "logo"
    text: "SpyMuseum"
  - title: ""
    text: ""

---

The Spy Museum is dedicated to tradecraft, history and contemporary role of espionage. They have a very nifty but a bit policy wonkish podcast that I'd recommend. The gift shop was surprisingly excellent and had an awesome book section. Many of the books were signed by the authors. They recently moved to a new bigger building, so I have a good excuse to visit again. Though the old building was near a hipster-ish but excellent pizza place with a good beer menu. 



<style>
    .image-gallery {overflow: auto; margin-left: -1%!important;}
    .image-gallery li {float: left; display: block; margin: 0 0 1% 1%; width: 19%;}
    .image-gallery li a {text-align: center; text-decoration: none!important; color: #777;}
    .image-gallery li a span {display: block; text-overflow: ellipsis; overflow: hidden; white-space: nowrap; padding: 3px 0;}
    .image-gallery li a img {width: 100%; display: block;}
</style>

<ul class="image-gallery">
{% for gallery_image in site.galleries['SpyMuseum'] %}
<li><a class="fancybox" href="{{ gallery_image.path }}"><img src="{{ gallery_image.thumbs['150x150'].path }}"></a></li>
{% endfor %}
</ul>
