---
title: "Philadelphia Museum of Art "
excerpt: "Yes, where Rocky ran up the stairs"
tags:
  - gallery
location:
    latitude: 
    longitude: 
header:
  image: /assets/images/PhillyMuseumArt-header-01.jpg
  teaser: /assets/images/PhillyMuseumArt-teaser-01-th.jpg
sidebar:
  - title: "Role"
    image: http://placehold.it/350x250
    image_alt: "logo"
    text: "PhillyMuseumArt"
  - title: ""
    text: ""

---

Philly Museum of Art has over 240,000 objects on display and is one of the largest art museums in the world. And has a bunch of annexes. Fantastically, they have the second largest collection of Rodin's sculptures in the world. The largest being in France. Rodin has always been my favorite artist. He did the Thinker sculpture that is fairly universally known. The Perelman Building has tons of textile art and costumes. There is also a sculpture of Rocky is at the base of the stairs. Which yes, people run up all the time.

If you love armor, you're in luck with the Carl Otto Kretzschmar von Kienbusch Collection. There's every type of European armor one can imagine, plus a decent sprinkling of Asian armor.

It's one of my favorite art museums, and I try to visit at least once a year. Oh, and skip the modern art section. It's terrible every visit. 


<style>
    .image-gallery {overflow: auto; margin-left: -1%!important;}
    .image-gallery li {float: left; display: block; margin: 0 0 1% 1%; width: 19%;}
    .image-gallery li a {text-align: center; text-decoration: none!important; color: #777;}
    .image-gallery li a span {display: block; text-overflow: ellipsis; overflow: hidden; white-space: nowrap; padding: 3px 0;}
    .image-gallery li a img {width: 100%; display: block;}
</style>

<ul class="image-gallery">
{% for gallery_image in site.galleries['PhillyMuseumArt'] %}
<li><a class="fancybox" href="{{ gallery_image.path }}"><img src="{{ gallery_image.thumbs['150x150'].path }}"></a></li>
{% endfor %}
</ul>
