---
title: "Penn Museum"
excerpt: "University of Pennsylvania Museum of Archaeology and Anthropology"
tags:
  - gallery
location:
    latitude: 
    longitude: 
sidebar:
  - title: "Role"
    image: http://placehold.it/350x250
    image_alt: "logo"
    text: "PennMuseum"
  - title: ""
    text: ""

---

As the name implies, Penn Museum is an archaeology and anthropology museum that is part of the University of Pennsylvania. They've conducted over 300 expeditions around the world, which is how they got the majority of their exhibits. Which has the nifty side benefit of having excellent context on their artifacts, which helps with research and analysis. Their collections are mostly divvied up between Mediterranean World, Egypt, the Near East, Mesopotamia, East Asia, and Mesoamerica.

The two exhibits that stuck out the most to me were the Roman coin room and the massive Egyptian room that looks like a brick crypt. Oh, and the skeletons on display in a glassed in conservation lab.



<style>
    .image-gallery {overflow: auto; margin-left: -1%!important;}
    .image-gallery li {float: left; display: block; margin: 0 0 1% 1%; width: 19%;}
    .image-gallery li a {text-align: center; text-decoration: none!important; color: #777;}
    .image-gallery li a span {display: block; text-overflow: ellipsis; overflow: hidden; white-space: nowrap; padding: 3px 0;}
    .image-gallery li a img {width: 100%; display: block;}
</style>

<ul class="image-gallery">
{% for gallery_image in site.galleries['PennMuseum'] %}
<li><a class="fancybox" href="{{ gallery_image.path }}"><img src="{{ gallery_image.thumbs['150x150'].path }}"></a></li>
{% endfor %}
</ul>
