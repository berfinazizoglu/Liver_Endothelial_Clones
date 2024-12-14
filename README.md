
Liver_endothelial_clones.m ReadMe

System Requirements
	- Matlab R2022b
	- Image Processing Toolbox Version 11.6 installed within Matlab

- This code was primarily run on a Mac OS Monterey 12.5 with 64 GB RAM. The code was successfully run on a Windows 11 operating system, with 16 GB RAM.

Installation
	Matlab: https://www.mathworks.com/help/install/ug/install-products-with-internet-connection.html
	Image Processing Toolbox: https://www.mathworks.com/products/image-processing.html
	Installing Matlab should take 30-45 minutes on a typical computer. 
	Installing the Toolbox should take less than 30 minutes. 

Demo
- The images provided in the Demo folder are ready to feed into the code. 
- We recommend downloading the demo images into a temporary folder on the local computer. The path for the image folder can be added in the code as the default path, “path=“.
- The minimum input files required for this code are maximum projection TIF files separately for PROCR and RFP channels corresponding to a single lobule. As such, full section maximum projection liver images are cropped on Fiji into single lobule images, followed by channel separation, and the PROCR and RFP are saved as TIF files.
- This code reads input files titled as “Image1_Procr.tif” , “Image2_Procr.tif”, and “Image1_RFP.tif” , “Image2_RFP.tif”  etc. The file names can be revised as necessary to match user preferences and needs.
- The output is 2 CSV files per input image pair (PROCR and RFP). One contains data for all clones, and the other data for all single cells. CSV files can be opened and analyzed in Numbers or Excel.
- The run time for a single demo image pair on a typical computer should take anywhere from 2-15 minutes.

Instructions:
	- Start running the Matlab code
	- Enter sample ID in “sample_ID”. This will help organize the output data files.
	- Enter the folder path where the demo image files are located in “path=“.
	- Enter the identifier number of the image in “image number=“. Example: If the images to be run are Image2_Procr and Image2_RFP, type in “2”.
	- Matlab will now bring up the Procr image 
		- Using your cursor, draw a line to separate the periphery from the core using Procr+ outlines of lobules. Once edge of the section is reached, close the path to isolate the core by drawing around the liver section on its inner portion. The goal is to 		delete the core area to analyze clones only in the periphery.
		- Repeat to analyze the clones in the core, this time deleting the periphery area when prompted with the Procr image. To do this, once edge of the section is reached, close the path by drawing around the liver section on its outer portion. This will 		delete the periphery area.
	- After the code is complete, check the outlines/overlays to make sure you are happy with core/periphery separation. 

Last Edited 12/14/2024 - D. Berfin Azizoglu
