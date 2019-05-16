# ds131.3 Curation

## Scripts

- [Jump to](#convert_yearly_gribs) `convert_yearly_gribs.sh` - Processes a years worth 20CRv3 files
- [Jump to](#runAll) `runAll.sh` - Initiates runs. Can specify range of years.
- [Jump to](#runYear) `runYear.sh` - Runs one year and given run type (fg, mean, spread)
- [Jump to](#slurm_job) `slurm_job.tcsh` - batch script to run on slurm.

## convert_yearly_gribs

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
---

## runAll

This program will run multiple years of 20CRv3. This is the highest level program.

### Usage
```
./runAll.sh [start year] [end year]
```

### Example
This will queue jobs from 1888 to 1903. The number of jobs would be (1903 - 1888) * 4.
```
./runAll.sh 1888 1903
```

## runYear

This program executes a job for one year.

### Usage

```
./runYear [/path/to/CR20/files/<year>] [file type]
```

### Example


```
./runYear /scratch/CR20v3/1999/ mean
```

## slurm_job

### Usage
