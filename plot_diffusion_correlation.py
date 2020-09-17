# plot the regression of diffusion with behavioral parameters
# the function should take a 4D volume of skeletonized dMRI, the behavioral design.mat and a voxel coordinate to extract
# values from
# the function should return one plot and r value
# the voxel coordinate should be a list


def plot_diffusion_correlation(skelet_4D_image, mat, voxel_coordinate):
    import numpy as np
    import matplotlib.pyplot as plt
    import nipype.interfaces.fsl as fsl
    import ntpath
    import sys
    import matplotlib
    import os

    img_basename_no_ext = ntpath.basename(skelet_4D_image)[:-7]
    mat_basename_no_ext = ntpath.basename(mat)[:-4]

# we use fslmeants from fsl to get the intensity of the 4D image from a specific coordinate
# fslmeants -i 4d_image -c 47 73 9
    fslmeants = fsl.ImageMeants()
    fslmeants.inputs.in_file = skelet_4D_image
    fslmeants.inputs.spatial_coord = voxel_coordinate
    outputs = fslmeants.run()
    # here the output is not displayed on the screen, rather as a simple txt
    # the return results are in dict format, we extract the name of the file
    ts = outputs.outputs.get()['out_file']
    voxel_values = np.loadtxt(ts)  # returns the values as an array
    voxel_values = list(voxel_values)

    # now we extract the behavior vector from .mat file
    f = open(mat, 'r')
    lines = f.readlines()
    f.close()
    behav = []
    i = 5
    for item in lines:
        while i < 34:
            behav.append(float(lines[i][13:-2]))
            i = i + 1
            # now we have a list
    # sanity check
    print("length of voxel_values -> {0}".format(len(voxel_values)))
    print("length of behav_values -> {0}".format(len(behav)))
    if len(voxel_values) != len(behav):
        sys.error('######ERROR####')

    # the regression line
    coef = np.polyfit(voxel_values, behav, 1)
    poly1d_fn = np.poly1d(coef)

    # get the correlation coeeficient
    # round to 4 digits after the decimal point
    correlation_coef = round(np.corrcoef(voxel_values, behav)[0, 1], 5)

    plt.scatter(voxel_values[16:], behav[16:], marker='<', color='b')
    plt.scatter(voxel_values[:16], behav[:16], marker='o', color='r')
    plt.plot(voxel_values, poly1d_fn(voxel_values), 'k')  # plot the regression line
    # type the coef on the graph, first two arguments the coordinates of the text (top left corner)
    plt.text(min(voxel_values), max(behav), "r $= {0}$".format(
        correlation_coef), fontname="Arial", style='italic')

    plt.savefig("/Users/amr/Dropbox/thesis/diffusion/DTI_corr/{0}_{1}.svg".format(
        img_basename_no_ext, mat_basename_no_ext), format='svg')
    plt.close()

    os.remove(ts)  # delete the file of the voxel values as it is no longer needed


# =======================================================================================================
img = '/Volumes/Amr_1TB/DTI_corr/Diffusion_TBSS_Stat/Study_Based_Template/CHARMED/CHARMED_FA/All_CHARMED_FA_Study_skeletonised.nii.gz'
mat = '/Volumes/Amr_1TB/DTI_corr/DTI_corr_designs/OF_total_distance.mat'
voxel = [67, 67, 8]

plot_diffusion_correlation(img, mat, voxel)
