setQC - A automatic report generating app
============================================================
Time-stamp: "2017-12-12 13:02:33"

# Scripts 
1. `setQC_wrapper_any.sh`: 

## Input 
1. `sample.txt`: a txt file includes all the sample names for this report. 

## Output 
### report link
1. example: <http://epigenomics.sdsc.edu:8084/2017-10-25-sswangson_morgridge/07e71bc01fec2c53bdc3776d8ada29cc/chu_hsap/setQC_report_any.html>
2. interpretion: `http://[base_url][-b][hash][-n]setQC_report_any.html.`

# Steps 

1. run multiQC: `runMultiQC.sh`:
2. Prepare  tracks data:
   * pull tracks from scratch folder to the `setQC/data` folder 
   * get individual `tracks.json` files and cat togaher 
   * make track json: `genWashUtracks.R`: 
     * input `set_dir`: dir under the base 
3. Calculate fc over the merged peak locations `calcOverlapAvgFC.sh`
   * make merged peak bed 
   * clip and sort the bed 
   * `bigWigAvergaeOverBed` to generate `avgOverlapFC.tab` file 
4. generate setQC report 
   * need to be `bds_atac_py3` environment
5. uploading files to server 
   * regular files: create by `cp -rs` 
   * apps 

# setQC reports: 
1. Sample info
2. Fastq QCs 
3. Mappability 
4. Peaks 
5. LibQC tables 
6. tracks 
7. data files 

# run script
``` Shell
setQC_wrapper_any.sh -s ~/scratch/others/2017-10-25-sswangson_morgridge/chu_hsap/uniq_samples_rev.txt \
    -b 2017-10-25-sswangson_morgridge -n chu_hsap -l ~/scratch/others/2017-10-25-sswangson_morgridge/chu_hsap/
```

