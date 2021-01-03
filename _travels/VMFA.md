---
title: "Virginia Museum of Fine Arts"
excerpt: "A massive art museum in Richmond"
tags:
  - gallery
location:
    latitude: 
    longitude: 
sidebar:
  - title: "Role"
    image: http://placehold.it/350x250
    image_alt: "logo"
    text: "VMFA"
  - title: ""
    text: ""

---

VMFA is another one of the largest art museums in North America. One of the centerpieces of the museum is the largest public collection of Fabergé eggs outside of Russia.


<style>
    .image-gallery {overflow: auto; margin-left: -1%!important;}
    .image-gallery li {float: left; display: block; margin: 0 0 1% 1%; width: 19%;}
    .image-gallery li a {text-align: center; text-decoration: none!important; color: #777;}
    .image-gallery li a span {display: block; text-overflow: ellipsis; overflow: hidden; white-space: nowrap; padding: 3px 0;}
    .image-gallery li a img {width: 100%; display: block;}
</style>

<ul class="image-gallery">
{% for gallery_image in site.galleries['VMFA'] %}
<li><a class="fancybox" href="{{ gallery_image.path }}"><img src="{{ gallery_image.thumbs['150x150'].path }}"></a></li>
{% endfor %}
</ul>
