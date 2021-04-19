#!/bin/bash

# a simple script to create multislice images overlaying stat images on top of FA study template

# the script takes three arguments from the CommandLine
# 1 -> stat image with absolute path
# 2 -> a string to append to the name whether behavior or tbss (or anything else)


# example:
# >>> create_FA_study_figures.sh \
# >>> /Users/amr/Dropbox/thesis/diffusion/to_FA_temp/CHARMED_FA_P_value1.nii.gz \  # stat image with abs path
# >>> behavior    # domain name


mkdir '/Users/amr/Dropbox/thesis/diffusion/to_FA_temp/'
dir='/Users/amr/Dropbox/thesis/diffusion/to_FA_temp/'


fsleyes='pythonw /Users/amr/anaconda3/bin/fsleyes' #aliases do not work inside scripts
FA_template='/Users/amr/Dropbox/thesis/registration/FA_Template_Cluster.nii.gz'
FA_template_skeleton='/Users/amr/Dropbox/thesis/registration/FA_Template_Cluster_Skeleton.nii.gz'
stat_map=`remove_ext $1`

#behavior or tbss
domain=$2

if [ ${domain} == 'tbss' ];then
    stat_map_name=`echo ${stat_map} | sed  s/.*_map_id_// | sed s[/palm.*[[`
elif [ ${domain} == 'behavior' ];then
    stat_map_name=`basename ${stat_map}`
    #get the name of the behav module
    mod=`dirname ${stat_map} | sed s[/Users/amr/Dropbox/thesis/diffusion/DTI_corr/[[ | sed s[.con.*[[`
    stat_map_name=${mod}_${stat_map_name}
fi


contrast_no=`echo ${stat_map: -1}`

# colormap -> from the contrast  #red-yellow or blue-lightblue
# if you entered 1 -> red-yellow colormap
# if you entered 2 (or anything else) -> blue-lightblue colormap

if [ ${contrast_no} -eq 1 ];then
	colormap='red-yellow'
else
	colormap='blue-lightblue'
fi



for slice_no in {12,10,8,6,4,2};do

	${fsleyes} render  \
	--scene ortho -no   --displaySpace world --hidex --hidey    -vl 52 68 ${slice_no} \
	--hideCursor   --outfile    ${dir}/${stat_map_name}_${domain}_render_${slice_no}.png   \
	${FA_template} --displayRange 3 30  \
	${FA_template_skeleton} --cmap green --displayRange 15 40 \
	${stat_map} --displayRange 0.95  1 --cmap ${colormap}

	convert  ${dir}/${stat_map_name}_${domain}_render_${slice_no}.png -crop 320x220+240+185  ${dir}/${stat_map_name}_${domain}_render_cropped_${slice_no}.png

done


pngappend \
${dir}/${stat_map_name}_${domain}_render_cropped_21.png + \
${dir}/${stat_map_name}_${domain}_render_cropped_26.png + \
${dir}/${stat_map_name}_${domain}_render_cropped_31.png + \
${dir}/${stat_map_name}_${domain}_render_cropped_36.png - \
${dir}/${stat_map_name}_${domain}_render_cropped_41.png + \
${dir}/${stat_map_name}_${domain}_render_cropped_46.png + \
${dir}/${stat_map_name}_${domain}_render_cropped_51.png + \
${dir}/${stat_map_name}_${domain}_render_cropped_56.png   \
${dir}/${stat_map_name}_${domain}_output_c${contrast_no}.png

# remove background
convert ${dir}/${stat_map_name}_${domain}_output_c${contrast_no}.png -transparent black ${dir}/${stat_map_name}_${domain}_output_no_bg_c${contrast_no}.png


# TODO: fix the script to agree with FA_template
# TODO: stat maps on one line
