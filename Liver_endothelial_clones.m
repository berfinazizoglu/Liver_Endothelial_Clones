%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%    Endothelial clone analysis in the liver    %%%%%%%%%%%%%%
%%%%%%%%%%%%%%             periphery versus core             %%%%%%%%%%%%%%
%%%%%%%%%%%%%%                                               %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Authors: Sherry Li Zheng, D. Berfin Azizoglu % 

%% OVERVIEW OF CODE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The purpose of this script is to analyze the spatial distribution of
% fluorescently labeled endothelial cell clones in the liver. It was used 
% to analyze the distribution of RFP-labeled clones in inducible 
% endothelial Cre; Confetti models. When Procr labeling is included, it 
% can assess clonal behavior in the periphery compared to the core of the 
% liver.
% 
% The Tamoxifen induction must be low enough to allow 
% for separation of labaled clones. In our hands, separation of clones by 
% 5 unlabeled cells on average at the time of analysis yields reliable 
% results.

% The input for this script is two tif files for each sample named 
% Image(number)_RFP and Image(number)_Procr in a folder entitled 
% with the sample ID. The "RFP" image contains the labeled endothelial clones 
% and the "Procr" image is used to distinguish the periphery from the 
% core of the liver. The path and input folders must be set up 
% accordingly.

% Below is an overview of the main steps and components:

% SECTION 1
    % Set sample IDs, path, structural elements, and create periphery
    % or core mask

% SECTION 2    
    % Create masks for clones

% SECTION 3        
    % Analysis of single cells

% SECTION 4
    % Export data in csv files


% The output of this script is three csv files for each sample. One 
% contains data for all clones; another contains data for all single cells;
% the last contains data on the Procr mask. 
% csv files can be opened and analyzed in Numbers or Excel.

% Questions or suggestions for improving this script? 
% Please email us at azizoglu_berfin@med.unc.edu

%% SECTION 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set sample and number of images included in analysis

sample_ID = ; %adjust to reflect correct sample number 

% Image naming conventions: for image number = N and marker X, 
    % file name is ImageN_X.tif
    
tic %starts timer

%% Add paths and create structural elements %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add path to images 
path = '';

% Create structural elements and labels/arrays for later analyses
disk_4 = strel('disk',4); %structural element (small disk)
disk_10 = strel('disk',10); %structural element (big disk)
disk_20 = strel('disk',20); %structural element (very big disk)

clone_sample_number = 0; %used to fill data cell array; do not adjust
singlecell_sample_number = 0; %used to fill data cell array; do not adjust
clone_data_cell_array = {}; %initialize data cell array
singlecell_data_cell_array = {}; %initialize data cell array

%% Manual inputs for Procr line mask %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

image_number = 1;
    
% Load Procr images
cd '';
unaltered_Procr_image=imread(strcat('Image',num2str(image_number),'_Procr.tif'));
    
% Create a binary mask for the periphery or the core by clicking and drawing continuously; release click to finish circle
figure; imshow(unaltered_Procr_image, []);
subtract_CV = imfreehand(); %click and draw, then release
deleted_CV_area = subtract_CV.createMask();
reverse_deleted_CV_area = imcomplement(deleted_CV_area); %zero out ROI 
    
    
    %% SECTION 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Create clone masks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Load clone images
    cd '';
    clone_image = imread(strcat('Image',num2str(image_number),'_RFP.tif'));
    
    % Zero out the area inside the mask
    adjusted_RFP = clone_image;
    adjusted_RFP(~reverse_deleted_CV_area) = 0;

    % Save as new RFP image
    file_location = fullfile('',sprintf(strcat('Image',num2str(image_number),'_RFP_',num2str(sample_ID),'.bmp')));
    imwrite(adjusted_RFP,file_location); %use this image for next section
    
    % Read adjusted RFP file
    cd '';
    clone_image = imread(strcat('Image',num2str(image_number),'_RFP_',num2str(sample_ID),'.bmp'));
    
    % Use background subtraction and intensity thresholding
    clone_subtract = clone_image-100;
    
    % Use dilation and erosion to connect overlapping clone masks
    clone_blur = imfilter(clone_subtract,fspecial('disk',3));
    clone_blur=bwareaopen(clone_blur,50);
    clone_dilate = imdilate(clone_blur,disk_20);
    clone_connect = imclose(clone_dilate,disk_10); 
    clone_with_single_cells_mask = imerode(clone_connect,disk_10); 
    
    % Filter out single cells
    clone_mask = bwareaopen(clone_with_single_cells_mask,1000); 
    original_clone_mask = clone_mask; %for later overlays
    
    % Export clone masks overlayed on original clone images to check for fit
    [clone_image_height,clone_image_width]=size(clone_image);
    clone_check=zeros(clone_image_height,clone_image_width,3);
    clone_check(:,:,1)=imadjust(mat2gray(clone_image));
    clone_check(:,:,2)=bwperim(clone_mask);
    file_location = fullfile('',sprintf(strcat(num2str(image_number),'_clone_masks_',num2str(sample_ID),'_RFP.jpg')));
    imwrite(clone_check,file_location); %check to make sure masks are precise and exclude single cells
    
     % Find clone centroid values and label clone masks
    clone_region_props1 = regionprops(clone_mask,'centroid','ConvexHull'); 
    clone_centroid_matrix1 = cat(1,clone_region_props1.Centroid);
    clone_length1 = length(clone_centroid_matrix1);
    
    % Remove any debris left over (due to rounding, etc) and check overlay
        clone_mask = bwareaopen(clone_mask,250);
        clone_mask_check=zeros(clone_image_height,clone_image_width,3);
        clone_mask_check(:,:,1)=bwperim(original_clone_mask);
        clone_mask_check(:,:,2)=bwperim(clone_mask);
        file_location = fullfile('',sprintf(strcat(num2str(image_number),'_clone_exclusion_',num2str(sample_ID),'_RFP.jpg')));
        imwrite(clone_mask_check,file_location); %red are excluded, yellow are included
        
        % Find centroid and area measurements for all included clones
        clone_region_props2 = regionprops(clone_mask,'area','centroid','PixelList','ConvexHull'); 
        clone_centroid_matrix2 = cat(1,clone_region_props2.Centroid);
        clone_length2 = length(clone_centroid_matrix2);
        clone_area_matrix = cat(1,clone_region_props2.Area); 
        filled_clone_mask = imfill(clone_mask, 'holes');
    
     %% Clone data calculations %%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
     for clone_number = 1:length(clone_centroid_matrix2(:,1))

                    % Perform calculations and fill data into arrays
                    clone_sample_number = clone_sample_number + 1;
                    identifier = strcat('image_',num2str(image_number),'_','clone_',num2str(clone_number),'_RFP');
                    clone_area_pixels = clone_area_matrix(clone_number,:);
                    clone_out_row = {identifier, clone_area_pixels};
                    clone_data_cell_array(clone_sample_number,:) = clone_out_row;
                    clone_out_row = {identifier, clone_area_pixels};
                    clone_data_cell_array(clone_sample_number,:) = clone_out_row;
   
     end
    
    %% SECTION 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Analysis of single cells %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Recover earlier intermediate clone mask (before single cells are filtered out) and filter out clones using size exclusion
    singlecell_mask = bwareafilt(clone_with_single_cells_mask,[0 300]); 
    original_singlecell_mask = singlecell_mask; %for later overlays
    
    % Export single cell masks overlayed on original images to check for fit
    singlecell_check=zeros(clone_image_height,clone_image_width,3);
    singlecell_check(:,:,1)=imadjust(mat2gray(clone_image));
    singlecell_check(:,:,2)=bwperim(singlecell_mask);
    file_location = fullfile('',sprintf(strcat(num2str(image_number),'_singlecell_masks_',num2str(sample_ID),'_RFP.jpg')));
    imwrite(singlecell_check,file_location); %check to make sure masks are precise and exclude clones
    
    %% Single cell analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Remove any debris left over (due to rounding, etc) and check overlay
        singlecell_mask = bwareaopen(singlecell_mask,50);
        singlecell_mask_check=zeros(clone_image_height,clone_image_width,3);
        singlecell_mask_check(:,:,1)=bwperim(original_singlecell_mask);
        singlecell_mask_check(:,:,2)=bwperim(singlecell_mask);
        file_location = fullfile('',sprintf(strcat(num2str(image_number),'_singlecell_exclusion_',num2str(sample_ID),'_RFP.jpg')));
        imwrite(singlecell_mask_check,file_location); %red are excluded, yellow are included

        % Find centroid and area measurements for all included single cells
        singlecell_region_props = regionprops(singlecell_mask,'area','centroid','PixelList'); 
        singlecell_area_matrix = cat(1,singlecell_region_props.Area); 
        singlecell_centroid_matrix = cat(1,singlecell_region_props.Centroid);
        singlecell_length = length(singlecell_centroid_matrix);

            
     %% Single cell data calculations %%%%%%%%%%%%%%%%%%%%%%
     
     % If there are no single cells, analysis ends here
    if singlecell_length == 0
        singlecell_sample_number = singlecell_sample_number + 1;
       	identifier = strcat('image_',num2str(image_number),'_RFP');
       	sc_out_row = {identifier, 'NA'};
      	singlecell_data_cell_array(singlecell_sample_number,:) = sc_out_row;
    
    % Otherwise, move on
    else
            for singlecell_number = 1:length(singlecell_centroid_matrix(:,1))
                    % Perform calculations and fill data into arrays
                    singlecell_sample_number = singlecell_sample_number + 1;
                    identifier = strcat('image_',num2str(image_number),'_','singlecell_',num2str(singlecell_number),'_RFP');
                    singlecell_area = singlecell_area_matrix(singlecell_number,:);
                    sc_out_row = {identifier, singlecell_area};
                    singlecell_data_cell_array(singlecell_sample_number,:) = sc_out_row;
            end
            
    end


%% SECTION 4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Export data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% csv file for clone data
clone_header = {'identifier', 'clone_area_pixles'};
clone_data_array = [clone_header; clone_data_cell_array];
cd '';
writecell(clone_data_array,strcat(num2str(sample_ID),'_raw_clone_data.csv'));

% csv file for single cell data
singlecell_header = {'identifier', 'singlecell_area'};
singlecell_data_array = [singlecell_header; singlecell_data_cell_array];
cd '';
writecell(singlecell_data_array,strcat(num2str(sample_ID),'_raw_singlecell_data.csv'));

toc %ends timer and returns elapsed time

%% END OF CODE & ACKNOWLEDGEMENTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Ellen Rim (Nusse Lab, Stanford University School of Medicine)
% Tanner Jensen and Colin Unger (Stanford University SOM and CS) 
