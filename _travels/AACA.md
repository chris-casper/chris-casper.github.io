---
title: "Antique Automobile Club of America Museum"
excerpt: "Automobile collector’s museum in Hershey, PA"
tags:
  - gallery
  - Museum
  - Hershey
location:
    latitude:
    longitude:
sidebar:
  - title: "Role"
    image: http://placehold.it/350x250
    image_alt: "logo"
    text: "AACA"
  - title: ""
    text: ""

---

[AACA Museum](https://www.aacamuseum.org/) is a nifty fairly large car museum that is a Smithsonian affiliate. They have permanent collections as well as special collections. The first time I visited they had a Lotus exhibit. The AACA Museum is in Hershey, PA and a stone's throw from Troeg Brewery, Outlet stores, Hershey Park, Hershey's Chocolate World, etc.

Their permanent collections are the Cammack Tucker Collection, Museum of Bus Transportation, the Kissmobile and the Historic Vehicle Association (HVA) display.

<div class="col-lg-3">
{% for gallery_image in site.galleries['AACA'] %}
 <a class="fancybox" href="{{ gallery_image.path }}">
 <img src="{{ gallery_image.thumbs['150x150'].path }}">
 </a>
{% endfor %}
</div>
