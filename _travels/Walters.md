---
title: "Walters Art Museum"
excerpt: "Probably my favorite art museum"
tags:
  - gallery
location:
    latitude: 
    longitude: 
sidebar:
  - title: "Role"
    image: http://placehold.it/350x250
    image_alt: "logo"
    text: "Walters"
  - title: ""
    text: ""

---

The Walters (father and son) collected a lot of art around the time of the Civil War and afterwards. When the son died, he left all that art to a public museum. It's not the largest museum, but it has the highest quality art. And matches my own tastes quite well. They have the largest collection of Gérôme's work in the US. It's a very diverse collection, but it tends towards a smaller amount of excellent examples rather than large numbers of more mundane works. 

The Peabody Library is right around the corner, and also worth a stop. 




<style>
    .image-gallery {overflow: auto; margin-left: -1%!important;}
    .image-gallery li {float: left; display: block; margin: 0 0 1% 1%; width: 19%;}
    .image-gallery li a {text-align: center; text-decoration: none!important; color: #777;}
    .image-gallery li a span {display: block; text-overflow: ellipsis; overflow: hidden; white-space: nowrap; padding: 3px 0;}
    .image-gallery li a img {width: 100%; display: block;}
</style>

<ul class="image-gallery">
{% for gallery_image in site.galleries['Walters'] %}
<li><a class="fancybox" href="{{ gallery_image.path }}"><img src="{{ gallery_image.thumbs['150x150'].path }}"></a></li>
{% endfor %}
</ul>
