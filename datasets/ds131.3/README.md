# ds131.3 Curation

## Scripts

- [Jump to](#Convert_yearly_gribs) `convert_yearly_gribs.sh` - Processes a years worth 20CRv3 files
- `runAll.sh` - 
- `runYear.sh`
- `slurm_job.tcsh`

## Convert_yearly_gribs

This program will attempt to process a given directory. Typically, a year's worth of files.

### Usage
```
convert_yearly_gribs [in_dir] [out_dir]
```

---
**NOTE**

The program assumes in_dir has 4 digits at the end specifying the year. 
Another assumption is that the directory stucture is as follows
```
1837122800/
    meananl_1837122800.grb2       
    pgrbenssprdanl_1837122800       
    pgrbensmeananl_1837122803.grb2       
    pgrbenssprdanl_1837122803       
    psobs_posterior.txt
    pgrbensmeanfg_1837122800_fhr06.grb2
    pgrbenssprdfg_1837122800_fhr06  
    psobs_prior.txt
    psobfile             
    psobs.txt
```
Where 
-----
