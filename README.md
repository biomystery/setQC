setQC - A automatic report generating app
============================================================
Time-stamp: "2017-11-07 15:28:47"

# Scripts 
1. `setQC_wrapper_any.sh`: 

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

## setQC reports: 

``` Shell
setQC_wrapper_any.sh -s ~/scratch/others/2017-10-25-sswangson_morgridge/chu_hsap/uniq_samples_rev.txt \
    -b 2017-10-25-sswangson_morgridge -n chu_hsap -l ~/scratch/others/2017-10-25-sswangson_morgridge/chu_hsap/
```

