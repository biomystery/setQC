hacked the default template @ Rmarkdown package to make it fit to the larger screen.

# location
/Library/Frameworks/R.framework/Versions/3.4/Resources/library/rmarkdown/rmd/h
cp ./default.html ~/data/software/miniconda3/envs/bds_atac/lib/R/library/rmarkdown/rmd/h/default.html 

# diff log:

125c125
<   max-width: 1200px; //940
---
>   max-width: 940px;
319,320c319
<   /*max-width: 1200px;*/
<   max-width: 1800px
---
>   max-width: 1200px;
370c369
< <div class="col-xs-12 col-sm-4 col-md-3 col-xl-2">
---
> <div class="col-xs-12 col-sm-4 col-md-3">
375c374
< <div class="toc-content col-xs-12 col-sm-8 col-md-9 col-xl-10">
---
 > <div class="toc-content col-xs-12 col-sm-8 col-md-9">



    
