---
title: "Wings of Freedom Aviation Museum"
excerpt: "Small but mighty"
tags:
  - gallery
  - Museum
  - aircraft
location:
    latitude: 
    longitude: 
sidebar:
  - title: "Role"
    image: http://placehold.it/350x250
    image_alt: "logo"
    text: "WFAM"
  - title: ""
    text: ""

---

Sadly most of the aircraft have been shipped off to other museums, but what remains is quite nice. They mostly have military aircraft, but good examples of a wild variety. It's worth visiting if you're just west of Philly. 



<style>
    .image-gallery {overflow: auto; margin-left: -1%!important;}
    .image-gallery li {float: left; display: block; margin: 0 0 1% 1%; width: 19%;}
    .image-gallery li a {text-align: center; text-decoration: none!important; color: #777;}
    .image-gallery li a span {display: block; text-overflow: ellipsis; overflow: hidden; white-space: nowrap; padding: 3px 0;}
    .image-gallery li a img {width: 100%; display: block;}
</style>

<ul class="image-gallery">
{% for gallery_image in site.galleries['WFAM'] %}
<li><a class="fancybox" href="{{ gallery_image.path }}"><img src="{{ gallery_image.thumbs['150x150'].path }}"></a></li>
{% endfor %}
</ul>
