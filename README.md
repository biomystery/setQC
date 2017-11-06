setQC - A automatic report generating app
============================================================
Time-stamp: "2017-11-06 15:01:54"


# Scripts 

1. `setQC_wrapper_any.sh`: 


# Steps 

1. run multiQC: `runMultiQC.sh`:
   
2. make track json: `genWashUtracks.R`: 
   * input `set_dir`: dir under the base 
   
3. generate setQC report 
   * `calcOvelapAvgFC.sh`: 
     * merge peak bed 
     * `bigWigAvergaeOverBed` to generate `avgOverlapFC.tab` file 
4. uploading files to server 
   * regular files 
   * apps 


## setQC reports: 

