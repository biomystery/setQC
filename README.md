setQC - A automatic report generating app
============================================================
Time-stamp: "2017-11-07 09:41:30"


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

     
     
6. uploading files to server 
   * regular files 
   * apps 


## setQC reports: 

