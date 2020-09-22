#!/bin/bash

# a simple script to create multislice images overlaying stat images on top of wmfod template

# the script takes three arguments from the CommandLine
# 1 -> stat image with absolute path
# 2 -> a string to append to the name whether behavior or tbss (or anything else)


# example:
# >>> create_wmfod_figures.sh \
# >>> /Users/amr/Dropbox/thesis/diffusion/to_wmfod_template/CHARMED_FA_P_value1.nii.gz \  # stat image with abs path
# >>> behavior    # domain name



dir='/Users/amr/Dropbox/thesis/diffusion/to_wmfod_template/'


fsleyes='pythonw /Users/amr/anaconda3/bin/fsleyes' #aliases do not work inside scripts
wmfod_template='/Users/amr/Dropbox/thesis/registration/wmfod_template.nii.gz'
wmfod_template_skeleton='/Users/amr/Dropbox/thesis/registration/wmfod_template_skeleton.nii.gz'
stat_map=`remove_ext $1`
stat_map_name=`echo ${stat_map} | sed  s/.*_map_id_// | sed s[/palm.*[[`
#behavior or tbss
domain=$2
contrast_no=`echo ${stat_map: -1}`

# colormap -> from the contrast  #red-yellow or blue-lightblue
# if you entered 1 -> red-yellow colormap
# if you entered 2 (or anything else) -> blue-lightblue colormap

if [ ${contrast_no} -eq 1 ];then
	colormap='red-yellow'
else
	colormap='blue-lightblue'
fi



for slice_no in {56,51,46,41,36,31,26,21};do

	${fsleyes} render  \
	--scene ortho -no   --displaySpace world --hidex --hidey    -vl 36 42 ${slice_no} \
	--hideCursor   --outfile    ${dir}/${stat_map_name}_${domain}_render_${slice_no}.png   \
	${wmfod_template} --displayRange 0.04 0.35  \
	${wmfod_template_skeleton} --cmap green --displayRange 0.2 0.3 \
	${stat_map} --displayRange 0.95  1 --cmap ${colormap}

	convert  ${dir}/${stat_map_name}_${domain}_render_${slice_no}.png -crop 320x220+245+185  ${dir}/${stat_map_name}_${domain}_render_cropped_${slice_no}.png

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
