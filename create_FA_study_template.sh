# Create an FA study-based template on the cluster

# the nipype script was stopped after fitting the tensor to generate the FA maps that were used in creating the template

# first move the FA maps form each subject after fitting the tensor to the directory...
# where I am going to create the template
cp /media/amr/Amr_4TB/Work/October_Acquistion/Diffusion_20_workingdir/DTI_workflow/_subject_id_???/fit_tensor/dtifit__FA.nii.gz \
/media/amr/HDD/Work/October_Acquistion/FA_template/


# ants buildtemplateparallel.sh script
# c 2 to run parallel on localhost or 5 to run on SLURM
cd /home/in/aeed/FA_Template

buildtemplateparallel.sh \
-d 3 \
-o 3D \
-c 5 \
-i 20 \
-j 400 \
-m 30x50x20 \
-r 1 \
*.nii.gz

mv 3Dtemplate.nii.gz FA_Template_Cluster.nii.gz

# then download it to the local drive
