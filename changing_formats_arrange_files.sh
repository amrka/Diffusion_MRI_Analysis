#!/bin/bash


# # processing of new subjects entitled October acquistions
# cd '/media/amr/HDD/Work/October_Acquistion/Autism_Original' 
# pwd
# for folder in *;do
# 	cd  $folder;
# 	pwd $folder
#	pvconv.pl $folder -outdir $folder
# 	for image in *.img;do
# 		fslchfiletype NIFTI $image
# 		fslorient -setqformcode 1 $image;
# 	done
# 	cd ..
# done




#Take each subject and transfer its data to its respective folder
#rs-fMRI >>> 750
#20dir  >>> 22
#45dir >>> 49
# mkdir '/media/amr/HDD/Work/October_Acquistion/Autism' 
# cd '/media/amr/HDD/Work/October_Acquistion/Autism_Original' 
# pwd 
# ls

# for folder in *;do
# 	cd  $folder;
# 	pwd $folder
# 	folder=${folder#*_};
# 	echo $folder
# 	mkdir '/media/amr/HDD/Work/October_Acquistion/Autism/'"$folder"'' 
# 	for img in *.nii;do
# 		dim4=`fslval $img dim4`
# 		dim3=`fslval $img dim3`
# 		if [ $dim4 -eq '750' ];then
# 			immv $img rs_fMRI
# 			imcp rs_fMRI '/media/amr/HDD/Work/October_Acquistion/Autism/'"$folder"''  
# 		elif [ $dim4 -eq '49' ];then
# 			immv $img Diff_45
# 			imcp Diff_45 '/media/amr/HDD/Work/October_Acquistion/Autism/'"$folder"'' 
# 		elif [ $dim4 -eq '22' ];then
# 			immv $img Diff_20
# 			imcp Diff_20 '/media/amr/HDD/Work/October_Acquistion/Autism/'"$folder"'' 
# 		elif [ $dim4 -eq '1' ];then
# 			if [ $dim3 -eq '80' ];then
# 				immv $img 3D
# 				imcp 3D '/media/amr/HDD/Work/October_Acquistion/Autism/'"$folder"''
# 			elif [ $dim3 -eq '16' ];then
# 				immv $img Anat
# 				imcp Anat '/media/amr/HDD/Work/October_Acquistion/Autism/'"$folder"''
# 			fi
# 		fi
# 	done
# 	cd ..
# done
	

#write some code to make sure the name of the subject inside the raw data
# is the samw as it is in the folder
#the txt file subject inside the raw data has the 25th line contains the 
#the name of subject as I gave it to the guys at the MRI

# cd '/media/amr/HDD/Work/October_Acquistion/Autism_Original' 

# for folder in *;do
# 	cd $folder
# 	pwd
# 	subject=subject
# 	day=`sed '10q;d' $subject`;
# 	num=`sed '25q;d' $subject`;
# 	echo ${day}_${num} 
# 	cd ..
# done


#Swap dimensions for all the images
# cd /media/amr/HDD/Work/October_Acquistion/Autism/
# for folder in *;do
# 	cd $folder
# 	pwd
# 	for img in *.nii;do
# 		fslchfiletype NIFTI_GZ $img

# 		fslswapdim $img RL AP IS $img
# 		fslorient -deleteorient $img
# 		fslorient -setsformcode 1 $img	
# 	done
# 	cd ..
# done

#the next step was to manually draw a mask on the anatomical images
#First I want to ckeck that all the subjects have masks, all masks have 16 slices(dim3)
#which means I did not forget anything
# cd /media/amr/HDD/Work/October_Acquistion/Autism/
# pwd

# for folder in *;do
# 	cd $folder
# 	pwd
# 	ls M*
# 	fslval M* dim3

# 	cd ..
# done

#Now we multiply each img by its mask to remove the skull
#and augment to make the template
#antsBuildTemplateparallel works with augmented images

#N.B I already wrote a script called Augment.sh to augment the images by a certain factor
#It also applies the setsfromcode 1
# cd /media/amr/HDD/Work/October_Acquistion/Autism/

# for folder in *;do
# 	cd $folder
# 	pwd
# 	#multiplication does not affect the orientation at all
# 	#you just take the mask directly from itksnap to multiplication directly
# 	fslmaths Anat -mul Mask Anat_Bet
# 	#The problem is the augmentation
# 	#My newly written script Augment.sh solves this problem
# 	#So, instead of using fslchpixdim, use Augment.sh filename factor TR
# 	Augment.sh Anat_Bet 10 2.5
# 	Augment.sh Mask     10 2.5
# 	#I am augmenting just the skull-stripped image and the mask as I am currently
# 	#occupied the anatomical images and the template
# 	cd ..
# done
# Now, the orientations are correct. I tested it with the Agarose subject
# the catach is that the orienntation is correct accordong to the viewer you are using
#the R and L are the real R and L

#----------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------

#Now, I want to make an antomical template from all my studies to serve as study template
#but first I want to check if the anatomical images look okay after skull stripping
#In order to do that, I will transfer the images to the directory where I am going to make
#the template, then use the fsl built-in script, slices, to make images 	

#I also have to add the subject's number to the image name, other wise I will have a problem
#moving them to the same folder

# mkdir /media/amr/HDD/Work/October_Acquistion/Anat_Template/
# cd /media/amr/HDD/Work/October_Acquistion/Autism/
# for folder in *;do
# 	echo $folder
# 	cd $folder
# 	#immv Anat_Bet Anat_Bet_${folder}
# 	imcp Anat_Bet_${folder} /media/amr/HDD/Work/October_Acquistion/Anat_Template/
# 	cd ..
# done

# cd /media/amr/HDD/Work/October_Acquistion/Anat_Template/
# #convert to nifti, because faster
# for image in *.nii.gz;do
# 	fslchfiletype NIFTI $image
# 	img=`remove_ext $image`
# 	slices $image -o $img
# done



#Now we build the template using ants
# cd /media/amr/HDD/Work/October_Acquistion/Anat_Template/

# buildtemplateparallel.sh \
# -d 3 \
# -o Anat_Template \
# -c 2 \
# -j 7 \
# -r 1 \
# *.nii


# immv Anat_Templatetemplate Anat_Template
# imcp Anat_Template /media/amr/HDD/Work/October_Acquistion/


#Augment the resting-state data
#cd /media/amr/HDD/Work/October_Acquistion/Autism/
# for folder in *;do
# 	cd $folder
# 	pwd
# 	img='rs_fMRI.nii.gz'
# 	Augment.sh $img 10 2
# 	fslval $img pixdim1 
# 	fslval $img pixdim4
# 	cd ..
# done


#Put the name of the folder with resting and mask data
#I really do not know why I am doing this, but I believe it will come handy later
# cd /media/amr/HDD/Work/October_Acquistion/Autism/
# for folder in *;do
# 	cd $folder
# 	pwd
# 	immv rs_fMRI rs_fMRI_${folder}
# 	immv Mask Mask_${folder}
# 	cd ..
# done



#Convert everything to nii to fasten the excution
#You do not have enoguh space for this, Asshole
# cd /media/amr/HDD/Work/October_Acquistion/Autism/

# for folder in *;do
# 	cd $folder
# 	pwd
# 	for img in *.nii.gz;do
# 		fslchfiletype NIFTI $img
# 	done
# 	cd ..
# done




#I mad a manual mask of the rs_fMRI data using ITK-Snap
#In order to be able to do everything in (including smoothing in epi space)
#So, I am going to use resting state mask to mask the epi, 
#instead of the anatomical one I used to use.

#Then use the python script
# python2 Amr_Data_Nipype.py

#then to regress out bad components and amove the images from native space to study
#template space
# python2 meta_flow_rs_fmri.py
#I saved the list of subjects after regressing out bad -components and registering to this awsome list
subj_list='/media/amr/HDD/Work/October_Acquistion/meta_flow_workingdir_rs_fmri/melodic_list_october_acquistions.txt'
#Now, I am off to start group MELODIC with 10, 15 and 20 IC
std='/media/amr/HDD/Work/October_Acquistion/Anat_Template.nii.gz'

#---------------------------------------------10-------------------------------------------


#I do not have space on my hard drive, I have to use the external one
# cd /media/amr/AMR_FAWZY/Octuber_MELODIC
# mkdir resting_state_Melodic+DualRegression_10_IC

# cd /media/amr/AMR_FAWZY/Octuber_MELODIC/resting_state_Melodic+DualRegression_10_IC


# while read -r line; do imcp $line \
# /media/amr/AMR_FAWZY/Octuber_MELODIC/resting_state_Melodic+DualRegression_10_IC; \
# done < '/media/amr/HDD/Work/October_Acquistion/meta_flow_workingdir_rs_fmri/melodic_list_october_acquistions.txt'

#Now, modify the names to remove all the shit, just keep the name
# cd /media/amr/AMR_FAWZY/Octuber_MELODIC/resting_state_Melodic+DualRegression_10_IC

# for image in *.nii.gz;do
# 	name=`remove_ext $image`
# 	name=`echo $image | tr -dc '0-9'`
# 	immv $image regfilt_$name
# done

#I copied the full list of the subjects with full path
list_10='/media/amr/AMR_FAWZY/Octuber_MELODIC/Melodic_Subjects_10.txt'
list_15='/media/amr/AMR_FAWZY/Octuber_MELODIC/Melodic_Subjects_15.txt'
list_20='/media/amr/AMR_FAWZY/Octuber_MELODIC/Melodic_Subjects_20.txt'
#---------------------------------------------10-----------------------------------------------

# cd /media/amr/AMR_FAWZY/Octuber_MELODIC/resting_state_Melodic+DualRegression_10_IC

# melodic \
# -i /media/amr/AMR_FAWZY/Octuber_MELODIC/Melodic_Subjects_10.txt \
# -a concat \
# --bgimage=$std \
# -d 10 \
# --nobet  \
# --bgthreshold=10.00 \
# --tr=2.00000 \
# --mmthresh=0.50000 \
# --Oall \
# -o /media/amr/AMR_FAWZY/Octuber_MELODIC/resting_state_Melodic+DualRegression_10_IC \
# --report \
# -v ;



#---------------------------------------------15-----------------------------------------------

# cd /media/amr/AMR_FAWZY/Octuber_MELODIC/
# mkdir resting_state_Melodic+DualRegression_15_IC

# cd /media/amr/AMR_FAWZY/Octuber_MELODIC/resting_state_Melodic+DualRegression_15_IC
	mkdir /media/amr/HDD/Work/October_Acquistion/Melodic_15 

melodic \
-i /media/amr/AMR_FAWZY/Octuber_MELODIC/Melodic_Subjects_15.txt \
-a concat \
--bgimage=$std \
-d 15 \
--nobet  \
--bgthreshold=10.00 \
--tr=2.00000 \
--mmthresh=0.50000 \
--Oall \
-o /media/amr/HDD/Work/October_Acquistion/Melodic_15 \
--report \
-v ;


#--------------------------------------------20----------------------------------------------

# cd cd /media/amr/AMR_FAWZY/Octuber_MELODIC/
# mkdir resting_state_Melodic+DualRegression_20_IC
# cd /media/amr/AMR_FAWZY/Octuber_MELODIC/resting_state_Melodic+DualRegression_20_IC

# melodic \
# -i /media/amr/AMR_FAWZY/Octuber_MELODIC/Melodic_Subjects_20.txt \
# -a concat \
# --bgimage=$std \
# -d 10 \
# --nobet  \
# --bgthreshold=10.00 \
# --tr=2.00000 \
# --mmthresh=0.50000 \
# --Oall \
# -o /media/amr/AMR_FAWZY/Octuber_MELODIC/resting_state_Melodic+DualRegression_20_IC \
# --report \
# -v ;

#------------------------------------------------------------------------------------------
#----------------------------------------------10--------------------------------------------
#Dual Regression
# cd /media/amr/AMR_FAWZY/Octuber_MELODIC/resting_state_Melodic+DualRegression_10_IC/

# design_ttest2 design 16 14;
# ls

# pwd


# dual_regression \
# /media/amr/AMR_FAWZY/Octuber_MELODIC/resting_state_Melodic+DualRegression_10_IC/melodic_IC.nii.gz \
# 1 \
# /media/amr/AMR_FAWZY/Octuber_MELODIC/resting_state_Melodic+DualRegression_10_IC/design.mat \
# /media/amr/AMR_FAWZY/Octuber_MELODIC/resting_state_Melodic+DualRegression_10_IC/design.con \
# 5000 \
# /media/amr/HDD/Work/October_Acquistion/Dual_Regression_10 \
# `cat /media/amr/AMR_FAWZY/Octuber_MELODIC/Melodic_Subjects_10.txt` -v;



# #----------------------------------------------15--------------------------------------------


cd /media/amr/HDD/Work/October_Acquistion/Melodic_15 
design_ttest2 design 16 14;
ls

pwd

dual_regression \
melodic_IC.nii.gz \
1 \
design.mat \
design.con \
5000 \
/media/amr/HDD/Work/October_Acquistion/Melodic_15/Dual_Regression_15 \
`cat /media/amr/AMR_FAWZY/Octuber_MELODIC/Melodic_Subjects_15.txt`;

# # #----------------------------------------------20--------------------------------------------

# cd /media/amr/AMR_FAWZY/Octuber_MELODIC/resting_state_Melodic+DualRegression_20_IC/


# design_ttest2 design 16 14;
# ls

# pwd

# dual_regression \
# melodic_IC.nii.gz \
# 1 \
# design.mat \
# design.con \
# 5000 \
# /media/amr/AMR_FAWZY/Octuber_MELODIC/resting_state_Melodic+DualRegression_20_IC/Dual_Regression \
# `cat /media/amr/AMR_FAWZY/Octuber_MELODIC/Melodic_Subjects_20.txt`;

