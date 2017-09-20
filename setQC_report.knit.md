---
params:
 libs_no: "48 49 50 51 52 53 54 55 56 57"
 set_no: "4_1"
 didTrim: "F"
title: "Report for Set6: JYH_42 43 44 45 46 47"
output:
 html_document:
   theme: united
   number_sections: no
   highlight: tango
   smart: TRUE
   toc: true
   toc_depth: 2
   toc_float: true
author: "Frank (zhangc518@gmail.com) @ UCSD Center for Epigenomics"
date: "Wed Sep 20 09:20:16 2017"
---
<hr style="border: 1px dashed grey;" />



# Sample info. 


Sample Index (from MSTS)   sample ID (from MSTS)   species (if preferred genome assembly, enter here)   Experiment Index (from METS)   Sequencing ID   Experiment type   Sequening core   Machine      Sequening length  Read type   i5 Index (or single index)   i7 index (if applicable) 
-------------------------  ----------------------  ---------------------------------------------------  -----------------------------  --------------  ----------------  ---------------  ----------  -----------------  ----------  ---------------------------  -------------------------
SAMP-10                    H7-SNAP-1               human                                                EXP-10                         JYH_42          ATAC-seq          LICR             HiSeq4000                  50  PE          S503                         N701                     
SAMP-11                    H7-SNAP-2               human                                                EXP-11                         JYH_43          ATAC-seq          LICR             HiSeq4000                  50  PE          S503                         N702                     
SAMP-12                    H7-SNAPDMSO-1           human                                                EXP-12                         JYH_44          ATAC-seq          LICR             HiSeq4000                  50  PE          S503                         N703                     
SAMP-13                    H7-SNAPDMSO-2           human                                                EXP-13                         JYH_45          ATAC-seq          LICR             HiSeq4000                  50  PE          S503                         N704                     
SAMP-14                    H7-SLOWDMSO-1           human                                                EXP-14                         JYH_46          ATAC-seq          LICR             HiSeq4000                  50  PE          S503                         N705                     
SAMP-15                    H7-SLOWDMSO-2           human                                                EXP-15                         JYH_47          ATAC-seq          LICR             HiSeq4000                  50  PE          S503                         N706                     

# QC of Fastq files

<!--html_preserve--><div class="col-sm-4">
<a class="thumbnail" title="" href="./multiqc_plots/png/mqc_fastqc_per_base_n_content_plot_1.png">
<img src="./multiqc_plots/png/mqc_fastqc_per_base_n_content_plot_1.png"/>
<div class="caption"></div>
</a>
</div><!--/html_preserve--><!--html_preserve--><div class="col-sm-4">
<a class="thumbnail" title="" href="./multiqc_plots/png/mqc_fastqc_per_base_sequence_quality_plot_1.png">
<img src="./multiqc_plots/png/mqc_fastqc_per_base_sequence_quality_plot_1.png"/>
<div class="caption"></div>
</a>
</div><!--/html_preserve--><!--html_preserve--><div class="col-sm-4">
<a class="thumbnail" title="" href="./multiqc_plots/png/mqc_fastqc_per_sequence_quality_scores_plot_1.png">
<img src="./multiqc_plots/png/mqc_fastqc_per_sequence_quality_scores_plot_1.png"/>
<div class="caption"></div>
</a>
</div><!--/html_preserve--><!--html_preserve--><div class="row"></div><!--/html_preserve--><!--html_preserve--><div class="col-sm-4">
<a class="thumbnail" title="" href="./multiqc_plots/png/mqc_fastqc_per_sequence_gc_content_plot_Percentages.png">
<img src="./multiqc_plots/png/mqc_fastqc_per_sequence_gc_content_plot_Percentages.png"/>
<div class="caption"></div>
</a>
</div><!--/html_preserve--><!--html_preserve--><div class="col-sm-4">
<a class="thumbnail" title="" href="./multiqc_plots/png/mqc_fastqc_sequence_duplication_levels_plot_1.png">
<img src="./multiqc_plots/png/mqc_fastqc_sequence_duplication_levels_plot_1.png"/>
<div class="caption"></div>
</a>
</div><!--/html_preserve--><!--html_preserve--><div class="col-sm-4">
<a class="thumbnail" title="" href="./multiqc_plots/png/mqc_fastqc_sequence_length_distribution_plot_1.png">
<img src="./multiqc_plots/png/mqc_fastqc_sequence_length_distribution_plot_1.png"/>
<div class="caption"></div>
</a>
</div><!--/html_preserve--><!--html_preserve--><div class="row"></div><!--/html_preserve-->

# QC of mappability
## Reads yeild table {.tabset .tabset-fade .tabset-pills}
### Read yield (%) after each step

<!--html_preserve--><div id="htmlwidget-5348a962e7c7be33513e" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-5348a962e7c7be33513e">{"x":{"filter":"none","data":[["Read count from sequencer","Read count successfully aligned","Read count after filtering for mapping quality","Read count after removing duplicate reads","Read count after removing mitochondrial reads (final read count)"],[1,0.844908497030229,0.627592575900498,0.546245879989282,0.462257567422769],[1,0.830994495891053,0.618206303407775,0.54577065179122,0.470727113084456],[1,0.778896751509089,0.537965636248285,0.441829318330546,0.342271812219565],[1,0.753035823756642,0.504216053599861,0.394277106630244,0.280945268220716],[1,0.635142083750092,0.391638413378107,0.303011821212392,0.211853180136442],[1,0.573479024018609,0.332955548665999,0.252065624530524,0.169060068746775]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>JYH_42<\/th>\n      <th>JYH_43<\/th>\n      <th>JYH_44<\/th>\n      <th>JYH_45<\/th>\n      <th>JYH_46<\/th>\n      <th>JYH_47<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[1,2,3,4,5,6]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false,"rowCallback":"function(row, data) {\nDTWidget.formatPercentage(this, row, data, 1, 0);\nDTWidget.formatPercentage(this, row, data, 2, 0);\nDTWidget.formatPercentage(this, row, data, 3, 0);\nDTWidget.formatPercentage(this, row, data, 4, 0);\nDTWidget.formatPercentage(this, row, data, 5, 0);\nDTWidget.formatPercentage(this, row, data, 6, 0);\n}"}},"evals":["options.rowCallback"],"jsHooks":[]}</script><!--/html_preserve-->

### Read counts after each step

<!--html_preserve--><div id="htmlwidget-b740c9c686b10b3a9974" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-b740c9c686b10b3a9974">{"x":{"filter":"none","data":[["Read count from sequencer","Read count successfully aligned","Read count after filtering for mapping quality","Read count after removing duplicate reads","Read count after removing mitochondrial reads (final read count)"],[32350644,27333334,20303024,17671406,14954330],[25477330,21171521,15750246,13904779,11992870],[16026888,12483291,8621915,7081149,5485552],[30396198,22889426,15326251,11984525,8539668],[28891622,18350285,11315069,8754503,6120782],[28435952,16307422,9467908,7167726,4807384]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>JYH_42<\/th>\n      <th>JYH_43<\/th>\n      <th>JYH_44<\/th>\n      <th>JYH_45<\/th>\n      <th>JYH_46<\/th>\n      <th>JYH_47<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[1,2,3,4,5,6]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false,"rowCallback":"function(row, data) {\nDTWidget.formatCurrency(this, row, data, 1, '', 0, 3, ',', '.', true);\nDTWidget.formatCurrency(this, row, data, 2, '', 0, 3, ',', '.', true);\nDTWidget.formatCurrency(this, row, data, 3, '', 0, 3, ',', '.', true);\nDTWidget.formatCurrency(this, row, data, 4, '', 0, 3, ',', '.', true);\nDTWidget.formatCurrency(this, row, data, 5, '', 0, 3, ',', '.', true);\nDTWidget.formatCurrency(this, row, data, 6, '', 0, 3, ',', '.', true);\n}"}},"evals":["options.rowCallback"],"jsHooks":[]}</script><!--/html_preserve-->

##  Mitochondrial reads fraction 

<!--html_preserve--><div id="htmlwidget-d895aeb291b158be4670" style="width:100%;height:500px;" class="highchart html-widget"></div>
<script type="application/json" data-for="htmlwidget-d895aeb291b158be4670">{"x":{"hc_opts":{"title":{"text":null},"yAxis":{"title":{"text":"Mitochondrial.reads..out.of.total."},"type":"linear"},"credits":{"enabled":false},"exporting":{"enabled":false},"plotOptions":{"series":{"turboThreshold":0,"showInLegend":false,"marker":{"enabled":true}},"treemap":{"layoutAlgorithm":"squarified"},"bubble":{"minSize":5,"maxSize":25},"scatter":{"marker":{"symbol":"circle"}}},"annotationsOptions":{"enabledButtons":false},"tooltip":{"delayForDisplay":10},"series":[{"group":"group","data":[{"Mitochondrial.reads..out.of.total.":0.323,"Fraction.of.reads.in.promoter.regions":0.0228,"Fraction.of.reads.in.called.peak.regions":0.108,"libs":"JYH_42","y":0.323,"name":"JYH_42"},{"Mitochondrial.reads..out.of.total.":0.308,"Fraction.of.reads.in.promoter.regions":0.0233,"Fraction.of.reads.in.called.peak.regions":0.108,"libs":"JYH_43","y":0.308,"name":"JYH_43"},{"Mitochondrial.reads..out.of.total.":0.488,"Fraction.of.reads.in.promoter.regions":0.337,"Fraction.of.reads.in.called.peak.regions":0.552,"libs":"JYH_44","y":0.488,"name":"JYH_44"},{"Mitochondrial.reads..out.of.total.":0.526,"Fraction.of.reads.in.promoter.regions":0.367,"Fraction.of.reads.in.called.peak.regions":0.611,"libs":"JYH_45","y":0.526,"name":"JYH_45"},{"Mitochondrial.reads..out.of.total.":0.527,"Fraction.of.reads.in.promoter.regions":0.376,"Fraction.of.reads.in.called.peak.regions":0.554,"libs":"JYH_46","y":0.527,"name":"JYH_46"},{"Mitochondrial.reads..out.of.total.":0.545,"Fraction.of.reads.in.promoter.regions":0.395,"Fraction.of.reads.in.called.peak.regions":0.562,"libs":"JYH_47","y":0.545,"name":"JYH_47"}],"type":"column"}],"xAxis":{"type":"category","title":{"text":"libs"},"categories":null}},"theme":{"chart":{"backgroundColor":"transparent"}},"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to {series.name}","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"type":"chart","fonts":[],"debug":false},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

## TSS enrichement plots

<!--html_preserve--><div class="col-sm-3">
<a class="thumbnail" title="JYH_42 : 2.412" href="./images/JYH_42_R1.fastq.bz2.PE2SE_large_tss-enrich.png">
<img src="./images/JYH_42_R1.fastq.bz2.PE2SE_large_tss-enrich.png"/>
<div class="caption">JYH_42 : 2.412</div>
</a>
</div>
<div class="col-sm-3">
<a class="thumbnail" title="JYH_43 : 2.349" href="./images/JYH_43_R1.fastq.bz2.PE2SE_large_tss-enrich.png">
<img src="./images/JYH_43_R1.fastq.bz2.PE2SE_large_tss-enrich.png"/>
<div class="caption">JYH_43 : 2.349</div>
</a>
</div>
<div class="col-sm-3">
<a class="thumbnail" title="JYH_44 : 28.27" href="./images/JYH_44_R1.fastq.bz2.PE2SE_large_tss-enrich.png">
<img src="./images/JYH_44_R1.fastq.bz2.PE2SE_large_tss-enrich.png"/>
<div class="caption">JYH_44 : 28.27</div>
</a>
</div>
<div class="col-sm-3">
<a class="thumbnail" title="JYH_45 : 30.63" href="./images/JYH_45_R1.fastq.bz2.PE2SE_large_tss-enrich.png">
<img src="./images/JYH_45_R1.fastq.bz2.PE2SE_large_tss-enrich.png"/>
<div class="caption">JYH_45 : 30.63</div>
</a>
</div>
<div class="col-sm-3">
<a class="thumbnail" title="JYH_46 : 34.02" href="./images/JYH_46_R1.fastq.bz2.PE2SE_large_tss-enrich.png">
<img src="./images/JYH_46_R1.fastq.bz2.PE2SE_large_tss-enrich.png"/>
<div class="caption">JYH_46 : 34.02</div>
</a>
</div>
<div class="col-sm-3">
<a class="thumbnail" title="JYH_47 : 35.24" href="./images/JYH_47_R1.fastq.bz2.PE2SE_large_tss-enrich.png">
<img src="./images/JYH_47_R1.fastq.bz2.PE2SE_large_tss-enrich.png"/>
<div class="caption">JYH_47 : 35.24</div>
</a>
</div><!--/html_preserve--><!--html_preserve--><div class="row"></div><!--/html_preserve-->

## Peak TSS enrichment and FRiT {.tabset .tabset-fade .tabset-pills}
### Max TSS enrichement compare

<!--html_preserve--><div id="htmlwidget-d920033e18ab98c8efe7" style="width:100%;height:500px;" class="highchart html-widget"></div>
<script type="application/json" data-for="htmlwidget-d920033e18ab98c8efe7">{"x":{"hc_opts":{"title":{"text":null},"yAxis":{"title":{"text":"TSS_enrichment"},"type":"linear"},"credits":{"enabled":false},"exporting":{"enabled":false},"plotOptions":{"series":{"turboThreshold":0,"showInLegend":false,"marker":{"enabled":true}},"treemap":{"layoutAlgorithm":"squarified"},"bubble":{"minSize":5,"maxSize":25},"scatter":{"marker":{"symbol":"circle"}}},"annotationsOptions":{"enabledButtons":false},"tooltip":{"delayForDisplay":10},"series":[{"group":"group","data":[{"libs":"JYH_42","TSS_enrichment":2.41194287324,"y":2.41194287324,"name":"JYH_42"},{"libs":"JYH_43","TSS_enrichment":2.3485233281,"y":2.3485233281,"name":"JYH_43"},{"libs":"JYH_44","TSS_enrichment":28.2707754615,"y":28.2707754615,"name":"JYH_44"},{"libs":"JYH_45","TSS_enrichment":30.6251278917,"y":30.6251278917,"name":"JYH_45"},{"libs":"JYH_46","TSS_enrichment":34.0158261925,"y":34.0158261925,"name":"JYH_46"},{"libs":"JYH_47","TSS_enrichment":35.2379471991,"y":35.2379471991,"name":"JYH_47"}],"type":"column"}],"xAxis":{"type":"category","title":{"text":"libs"},"categories":null}},"theme":{"chart":{"backgroundColor":"transparent"}},"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to {series.name}","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"type":"chart","fonts":[],"debug":false},"evals":[],"jsHooks":[]}</script><!--/html_preserve--><!--html_preserve--><div class="row"></div><!--/html_preserve-->

### FRiT (Fraction of reads in TSS) 

<!--html_preserve--><div id="htmlwidget-0f2c5a20cccc680b560a" style="width:100%;height:500px;" class="highchart html-widget"></div>
<script type="application/json" data-for="htmlwidget-0f2c5a20cccc680b560a">{"x":{"hc_opts":{"title":{"text":null},"yAxis":{"title":{"text":"Fraction.of.reads.in.promoter.regions"},"type":"linear"},"credits":{"enabled":false},"exporting":{"enabled":false},"plotOptions":{"series":{"turboThreshold":0,"showInLegend":false,"marker":{"enabled":true}},"treemap":{"layoutAlgorithm":"squarified"},"bubble":{"minSize":5,"maxSize":25},"scatter":{"marker":{"symbol":"circle"}}},"annotationsOptions":{"enabledButtons":false},"tooltip":{"delayForDisplay":10},"series":[{"group":"group","data":[{"Mitochondrial.reads..out.of.total.":0.323,"Fraction.of.reads.in.promoter.regions":0.0228,"Fraction.of.reads.in.called.peak.regions":0.108,"libs":"JYH_42","y":0.0228,"name":"JYH_42"},{"Mitochondrial.reads..out.of.total.":0.308,"Fraction.of.reads.in.promoter.regions":0.0233,"Fraction.of.reads.in.called.peak.regions":0.108,"libs":"JYH_43","y":0.0233,"name":"JYH_43"},{"Mitochondrial.reads..out.of.total.":0.488,"Fraction.of.reads.in.promoter.regions":0.337,"Fraction.of.reads.in.called.peak.regions":0.552,"libs":"JYH_44","y":0.337,"name":"JYH_44"},{"Mitochondrial.reads..out.of.total.":0.526,"Fraction.of.reads.in.promoter.regions":0.367,"Fraction.of.reads.in.called.peak.regions":0.611,"libs":"JYH_45","y":0.367,"name":"JYH_45"},{"Mitochondrial.reads..out.of.total.":0.527,"Fraction.of.reads.in.promoter.regions":0.376,"Fraction.of.reads.in.called.peak.regions":0.554,"libs":"JYH_46","y":0.376,"name":"JYH_46"},{"Mitochondrial.reads..out.of.total.":0.545,"Fraction.of.reads.in.promoter.regions":0.395,"Fraction.of.reads.in.called.peak.regions":0.562,"libs":"JYH_47","y":0.395,"name":"JYH_47"}],"type":"column"}],"xAxis":{"type":"category","title":{"text":"libs"},"categories":null}},"theme":{"chart":{"backgroundColor":"transparent"}},"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to {series.name}","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"type":"chart","fonts":[],"debug":false},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

## Insert size distribution 

<!--html_preserve--><div class="col-sm-12">
<a class="thumbnail" title="" href="./multiqc_plots/png/mqc_picard_insert_size_Percentages.png">
<img src="./multiqc_plots/png/mqc_picard_insert_size_Percentages.png"/>
<div class="caption"></div>
</a>
</div><!--/html_preserve-->

## GC bias in final bam 

<!--html_preserve--><div class="col-sm-12">
<a class="thumbnail" title="" href="./multiqc_plots/png/mqc_picard_gcbias_plot_1.png">
<img src="./multiqc_plots/png/mqc_picard_gcbias_plot_1.png"/>
<div class="caption"></div>
</a>
</div><!--/html_preserve-->

# QC of peaks {.tabset .tabset-fade .tabset-pills}
## Raw peak numbers 

<!--html_preserve--><div id="htmlwidget-845b7778a82782591927" style="width:100%;height:500px;" class="highchart html-widget"></div>
<script type="application/json" data-for="htmlwidget-845b7778a82782591927">{"x":{"hc_opts":{"title":{"text":null},"yAxis":{"title":{"text":"raw_peak_number"},"type":"linear"},"credits":{"enabled":false},"exporting":{"enabled":false},"plotOptions":{"series":{"turboThreshold":0,"showInLegend":false,"marker":{"enabled":true}},"treemap":{"layoutAlgorithm":"squarified"},"bubble":{"minSize":5,"maxSize":25},"scatter":{"marker":{"symbol":"circle"}}},"annotationsOptions":{"enabledButtons":false},"tooltip":{"delayForDisplay":10},"series":[{"group":"group","data":[{"raw_peak_number":242516,"lib":"JYH_42","y":242516,"name":"JYH_42"},{"raw_peak_number":206900,"lib":"JYH_43","y":206900,"name":"JYH_43"},{"raw_peak_number":146102,"lib":"JYH_44","y":146102,"name":"JYH_44"},{"raw_peak_number":192812,"lib":"JYH_45","y":192812,"name":"JYH_45"},{"raw_peak_number":149936,"lib":"JYH_46","y":149936,"name":"JYH_46"},{"raw_peak_number":113944,"lib":"JYH_47","y":113944,"name":"JYH_47"}],"type":"column"}],"xAxis":{"type":"category","title":{"text":"libs"},"categories":null}},"theme":{"chart":{"backgroundColor":"transparent"}},"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to {series.name}","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"type":"chart","fonts":[],"debug":false},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

## FRiP (Fraction of reads in Peak region)

<!--html_preserve--><div id="htmlwidget-31a3f2d65a1a1cdcb710" style="width:100%;height:500px;" class="highchart html-widget"></div>
<script type="application/json" data-for="htmlwidget-31a3f2d65a1a1cdcb710">{"x":{"hc_opts":{"title":{"text":null},"yAxis":{"title":{"text":"Fraction.of.reads.in.called.peak.regions"},"type":"linear"},"credits":{"enabled":false},"exporting":{"enabled":false},"plotOptions":{"series":{"turboThreshold":0,"showInLegend":false,"marker":{"enabled":true}},"treemap":{"layoutAlgorithm":"squarified"},"bubble":{"minSize":5,"maxSize":25},"scatter":{"marker":{"symbol":"circle"}}},"annotationsOptions":{"enabledButtons":false},"tooltip":{"delayForDisplay":10},"series":[{"group":"group","data":[{"Mitochondrial.reads..out.of.total.":0.323,"Fraction.of.reads.in.promoter.regions":0.0228,"Fraction.of.reads.in.called.peak.regions":0.108,"libs":"JYH_42","y":0.108,"name":"JYH_42"},{"Mitochondrial.reads..out.of.total.":0.308,"Fraction.of.reads.in.promoter.regions":0.0233,"Fraction.of.reads.in.called.peak.regions":0.108,"libs":"JYH_43","y":0.108,"name":"JYH_43"},{"Mitochondrial.reads..out.of.total.":0.488,"Fraction.of.reads.in.promoter.regions":0.337,"Fraction.of.reads.in.called.peak.regions":0.552,"libs":"JYH_44","y":0.552,"name":"JYH_44"},{"Mitochondrial.reads..out.of.total.":0.526,"Fraction.of.reads.in.promoter.regions":0.367,"Fraction.of.reads.in.called.peak.regions":0.611,"libs":"JYH_45","y":0.611,"name":"JYH_45"},{"Mitochondrial.reads..out.of.total.":0.527,"Fraction.of.reads.in.promoter.regions":0.376,"Fraction.of.reads.in.called.peak.regions":0.554,"libs":"JYH_46","y":0.554,"name":"JYH_46"},{"Mitochondrial.reads..out.of.total.":0.545,"Fraction.of.reads.in.promoter.regions":0.395,"Fraction.of.reads.in.called.peak.regions":0.562,"libs":"JYH_47","y":0.562,"name":"JYH_47"}],"type":"column"}],"xAxis":{"type":"category","title":{"text":"libs"},"categories":null}},"theme":{"chart":{"backgroundColor":"transparent"}},"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","drillUpText":"Back to {series.name}","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"thousandsSep":" ","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"type":"chart","fonts":[],"debug":false},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

# LibQC table 

<!--html_preserve--><div id="htmlwidget-271a810c26a178ee2ecd" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-271a810c26a178ee2ecd">{"x":{"filter":"none","data":[["sampleId","Genome","Paired/Single-ended","Read length","Read count from sequencer","Read count successfully aligned","Read count after filtering for mapping quality","Read count after removing duplicate reads","Read count after removing mitochondrial reads (final read count)","Mapping quality &gt; q30 (out of total)","Duplicates (after filtering)","Mitochondrial reads (out of total)","Duplicates that are mitochondrial (out of all dups)","Final reads (after all filters)","Raw peaks","Min size","25 percentile","50 percentile (median)","75 percentile","Max size","Mean","TSS_enrichment","Fraction of reads in promoter regions","Fraction of reads in called peak regions"],["H7-SNAP-1","hg38","Paired-ended","51","32350644","27333334","20303024","17671406","14954330","20303024 | 0.628","2631618.0 | 0.26","8836203 | 0.323","6576250 | 0.794","14954330 | 0.462","242516 - OK","150.0","150.0","150.0","203.0","1070.0","185.401256","2.41194287324","308114 | 0.0228","1462979 | 0.108"],["H7-SNAP-2","hg38","Paired-ended","51","25477330","21171521","15750246","13904779","11992870","15750246 | 0.618","1845467.0 | 0.235","6516486 | 0.308","4615546 | 0.793","11992870 | 0.471","206900 - OK","150.0","150.0","150.0","200.0","992.0","183.654789754","2.3485233281","251385 | 0.0233","1161167 | 0.108"],["H7-SNAPDMSO-1","hg38","Paired-ended","51","16026888","12483291","8621915","7081149","5485552","8621915 | 0.538","1540766.0 | 0.36","6096353 | 0.488","4263270 | 0.862","5485552 | 0.342","146102 - OK","150.0","150.0","214.0","373.0","2272.0","313.277189908","28.2707754615","1454869 | 0.337","2383678 | 0.552"],["H7-SNAPDMSO-2","hg38","Paired-ended","51","30396198","22889426","15326251","11984525","8539668","15326251 | 0.504","3341726.0 | 0.439","12046056 | 0.526","9425078 | 0.87","8539668 | 0.281","192812 - OK","150.0","150.0","216.0","385.0","2648.0","324.150841234","30.6251278917","2523404 | 0.367","4203081 | 0.611"],["H7-SLOWDMSO-1","hg38","Paired-ended","51","28891622","18350285","11315069","8754503","6120782","11315069 | 0.392","2560566.0 | 0.456","9674942 | 0.527","7315032 | 0.867","6120782 | 0.212","149936 - OK","150.0","150.0","203.0","339.0","2327.0","302.525517554","34.0158261925","1735302 | 0.376","2558606 | 0.554"],["H7-SLOWDMSO-2","hg38","Paired-ended","51","28435952","16307422","9467908","7167726","4807384","9467908 | 0.333","2300182.0 | 0.489","8884978 | 0.545","6692540 | 0.873","4807384 | 0.169","113944 - OK","150.0","150.0","214.0","370.0","2041.0","312.640042477","35.2379471991","1345855 | 0.395","1918554 | 0.562"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>JYH_42<\/th>\n      <th>JYH_43<\/th>\n      <th>JYH_44<\/th>\n      <th>JYH_45<\/th>\n      <th>JYH_46<\/th>\n      <th>JYH_47<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"order":[],"autoWidth":false,"orderClasses":false,"columnDefs":[{"orderable":false,"targets":0}]}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

# Tracks

<!--html_preserve--><a href="http://epigenomegateway.wustl.edu/browser/?genome=hg38&amp;tknamewidth=275&amp;datahub=http://epigenomics.sdsc.edu:8084/Set_6/data/tracks_merged_pf.json" class="btn btn-primary">Open WashU Genome Browser</a><!--/html_preserve--><!--html_preserve--><iframe class="embed-responsive-item" width="1340px" height="750px" src="http://epigenomegateway.wustl.edu/browser/?genome=hg38&amp;tknamewidth=275&amp;datahub=http://epigenomics.sdsc.edu:8084/Set_6/data/tracks_merged_pf.json"></iframe><!--/html_preserve-->


---
title: "setQC_report.R"
author: "zhc268"
date: "Wed Sep 20 09:20:15 2017"
---
