---
title: "Jekyll Photo Galleries"
excerpt: "Jekyll is pretty great, but has some weird edge cases"
last_modified_at: 2019-12-29 01:44:31
tags:
  - jekyll
---
<br />

## Jekyll. The Great and Weird.

Jekyll is a static site generator. Rather than deal with databases and other code generated each time someone visits the site, it pre-generates the entire web site. Paying the processing cost once, instead on every click. Not only is it faster, it's also infinitely more secure. There are few or no ways of attacking it. Compared to Wordpress, which tend to get hacked on a regular basis due to wonky plugins.

On the negative side, it can be weird and routine use-cases can be a pain to implement.

In this case, there's not a hugely great built in way to make large photo galleries. There's a very easy and labor intensive way to make a 'gallery' of a couple pics. Not so much if you have hundreds of pictures in dozens of folders.

I eventually did find a plugin that had potential to be a step in the right direction,
[Jekyll-galleryGenerator](https://github.com/kidtsunami/Jekyll-galleryGenerator). It's not actively maintained, so I forked a [copy](https://github.com/chris-casper/Jekyll-galleryGenerator) with a couple of minor fixes. It handles the thumbnail parts very well.

## Making a Template

I took a post, stripped out all of the content and added some dummy text (XXXXX in this case) to where I wanted to put the gallery tag.

This is the code I finally got to look pretty decent:

~~~~html
<style>
    .image-gallery {overflow: auto; margin-left: -1%!important;}
    .image-gallery li {float: left; display: block; margin: 0 0 1% 1%; width: 19%;}
    .image-gallery li a {text-align: center; text-decoration: none!important; color: #777;}
    .image-gallery li a span {display: block; text-overflow: ellipsis; overflow: hidden; white-space: nowrap; padding: 3px 0;}
    .image-gallery li a img {width: 100%; display: block;}
</style>

<ul class="image-gallery">
{% for gallery_image in site.galleries['XXXXX'] %}
<li><a class="fancybox" href="{{ gallery_image.path }}"><img src="{{ gallery_image.thumbs['150x150'].path }}"></a></li>
{% endfor %}
</ul>
~~~~

You can download a full version [here](https://raw.githubusercontent.com/chris-casper/Jekyll-Gallery-Generator/master/template.md). You probably want to nail down a really really good template before running the generator rather than afterwards, and having to edit dozens of markdown files.

Once you get the template down, it's time to make copies of the template. You can edit the copy line to dump the files somewhere specific. Or just move them. Either or.

~~~~bash
#!/usr/bin/env bash
for path in /path/to/_galleries/*; do
    [ -d "${path}" ] || continue # if not a directory, skip
    dirname="$(basename "${path}")"
    spath=$dirname
    cp template.md ${spath}.md
    sed -i "s|XXXXX|$spath|g" "${spath}.md"
done
~~~~

Full copy can be obtained from [here](https://raw.githubusercontent.com/chris-casper/Jekyll-Gallery-Generator/master/TemplateGenerator.sh).
