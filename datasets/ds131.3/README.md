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
convert_yearly_gribs [in_dir] [out_dir] [file_type]
```
  `in_dir`   - A parent directory to all files of needed file_type.
             This needs to be in form /path/to/files/{year} since the year is determined 
             By the direcory basename.
             
  `out_dir`   - location to create directory structure and place output files.
              Output files are stored in {out_dir}/{year}
              
  `file_type` - 'spread', 'mean', 'obs', 'meanfg', 'sprdfg', 'meansflx' or 'sprdsflx'
              This is the type of file that has special processing depending on type.
              Note: *sflx file types are not surface flux variables but rather 6hr analysis variables.
              The same is simply a carryover from an older version 
 
  This program first separates by like parameter, separates into similar levels,
  converts to grib2, and finally converts to netCDF4 with custom metadata.
  
A prerequisite to correctly running this is that a call to `separateByYear.sh` is needed first. This is needed as certain variables in the 'sflx' directories should be included in the 3h analysis and 3hr fg files.
 

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
