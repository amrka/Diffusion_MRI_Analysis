#!/bin/bash
#perform correlation analysis between behavior metrics and diffusion skeletons
# first copy the metrics from the ouput of the behavior ouput to here
# I am suspecting that a lot of the metrics are linear combinations of the others


# Copy the file that contains all the begavior from the VBM stat directory:
# They are well-organized and demeaned, so it is more convenient
# OF: /media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/open_field_gp_names.csv
# EPM: /media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/plus_maze_gp_names.csv

# animals: 236, 271, 272 are omitted, hence the difference
# for each column, I subtract the mean and create design from each one of them
# in those cases the DOF will be 29-2 (rows - columns(contrasts)) = 27

mkdir /media/amr/Amr_4TB/Work/October_Acquistion/DTI_corr/
mkdir /media/amr/Amr_4TB/Work/October_Acquistion/DTI_corr/DTI_corr_designs

cp \
/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/open_field_gp_names.csv \
/media/amr/Amr_4TB/Work/October_Acquistion/DTI_corr/DTI_corr_designs

cp \
/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/plus_maze_gp_names.csv \
/media/amr/Amr_4TB/Work/October_Acquistion/DTI_corr/DTI_corr_designs

# I edited the CSV files manually to remove the extra subjects
# I did the designs manually, by calling Glm and fill in the data from the CSV files
