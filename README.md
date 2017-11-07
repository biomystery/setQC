setQC - A automatic report generating app
============================================================
Time-stamp: "2017-11-07 10:20:20"


# Scripts 

1. `setQC_wrapper_any.sh`: 


# Steps 

1. run multiQC: `runMultiQC.sh`:
   
2. Prepare tracks: pull tracks from scratch folder to the `setQC/data` folder 
   * get individual `tracks.json` files and cat togaher 
   
3. make track json: `genWashUtracks.R`: 
   * input `set_dir`: dir under the base 

4. Calculate fc over the merged peak locations `calcOverlapAvgFC.sh`
   * make merged peak bed 
   * clip and sort the bed 
   * `bigWigAvergaeOverBed` to generate `avgOverlapFC.tab` file 

5. generate setQC report 
   * need to be `bds_atac_py3` environment
     
     
6. uploading files to server 
   * regular files 
   * apps 


## setQC reports: 

