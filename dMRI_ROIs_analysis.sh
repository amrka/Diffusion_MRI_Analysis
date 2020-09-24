#!/bin/bash


#make a directory for the two types of csv, tracts stat -> descriptive & metrics stat -> metrics

mkdir -p /Users/amr/Dropbox/thesis/diffusion/DTI_ROI/{descriptive,metrics}

cp /media/amr/Amr_4TB/Work/October_Acquistion/Diffusion_Multishell_ExploreDTI_workingdir/Multishell_ExploreDTI_workflow/_subject_id_*/ExploreDTI_calculate_tracts_from_masks/*Desc_Stats*.csv \
/Users/amr/Dropbox/thesis/diffusion/DTI_ROI/descriptive

cp /media/amr/Amr_4TB/Work/October_Acquistion/Diffusion_Multishell_ExploreDTI_workingdir/Multishell_ExploreDTI_workflow/_subject_id_*/ExploreDTI_calculate_tracts_from_masks/*_Others_Stats*.csv \
/Users/amr/Dropbox/thesis/diffusion/DTI_ROI/metrics

python /Users/amr/Dropbox/SCRIPTS/change_files_to_contain_gp_name.py \
/Users/amr/Dropbox/thesis/diffusion/DTI_ROI/descriptive/ -7 -4


python /Users/amr/Dropbox/SCRIPTS/change_files_to_contain_gp_name.py \
/Users/amr/Dropbox/thesis/diffusion/DTI_ROI/metrics/ -7 -4




cat << EOF > pyscript.py

#Python code to merge all the ROIs from all the subjects
import pandas as pd
import glob

dfs = sorted(glob.glob('/Users/amr/Dropbox/thesis/diffusion/DTI_ROI/descriptive/*Desc_Stats*.csv', ))

# they are sperated by a tab
result = pd.concat([pd.read_csv(df, sep='\t') for df in dfs])


result.to_csv('/Users/amr/Dropbox/thesis/diffusion/DTI_ROI/descriptive/merge_descriptive_dMRI.csv', header=True, index=False)

##############################

dfs = sorted(glob.glob('/Users/amr/Dropbox/thesis/diffusion/DTI_ROI/metrics/*Others_Stats*.csv', ))

# they are sperated by a tab
result = pd.concat([pd.read_csv(df).T for df in dfs])


result.to_csv('/Users/amr/Dropbox/thesis/diffusion/DTI_ROI/metrics/merge_metrics_dMRI.csv', header=True, index=True) #index=True, otherwise you lose the first column
# I edited this one by hand by removing rows of headers and inserted a column for the subjects names

EOF
# I also edited both csv files to remove index and header and named it *_for_palm.csv to suit palm (manually of course)

chmod 755 pyscript.py

./pyscript.py

palm \
-i /Users/amr/Dropbox/thesis/diffusion/DTI_ROI/descriptive/merge_descriptive_dMRI_for_palm.csv \
-d /media/amr/Amr_4TB/Work/October_Acquistion/Diffusion_TBSS_Stat/Design_TBSS.mat \
-t /media/amr/Amr_4TB/Work/October_Acquistion/Diffusion_TBSS_Stat/Design_TBSS.con \
-o /Users/amr/Dropbox/thesis/diffusion/DTI_ROI/descriptive/results_dMRI_ROIs_descrptive \
-corrcon -fdr -save1-p


# the default is 10,000 permutations, so no need to assert that

palm \
-i /Users/amr/Dropbox/thesis/diffusion/DTI_ROI/metrics/merge_metrics_dMRI_for_palm.csv \
-d /media/amr/Amr_4TB/Work/October_Acquistion/Diffusion_TBSS_Stat/Design_TBSS.mat \
-t /media/amr/Amr_4TB/Work/October_Acquistion/Diffusion_TBSS_Stat/Design_TBSS.con \
-o /Users/amr/Dropbox/thesis/diffusion/DTI_ROI/metrics/results_dMRI_ROIs_metrics \
-corrcon -fdr -save1-p



# nothing was significant
