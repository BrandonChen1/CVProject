function SetSolver(fileName)
    fileName = "~/Images/IMG_7534.jpg"
    defineBlackBoxes(fileName)
end

function defineBlackBoxes(fileName)
    image_in = "Images/IMG_7680.jpg";
    im_orig = imread(image_in);
    padvalue = 0; % or 1 if image is single, double, or logical.
    im_orig = padarray(im_orig, [20,20],255);
    grayscaleImage = rgb2gray(im_orig);
    %figure
    %imshow(im_orig);
    %figure
    %imshow(grayscaleImage);
    bwImage = im2bw(grayscaleImage,.3);
    %figure
    %imshow(bwImage)
    se = strel("disk", 8);
    bwImageOpened = imopen(bwImage, se);
    bwImageClosed = imclose(bwImageOpened,se);
%     figure
%     imshow(bwImageClosed);
    stats = regionprops(bwImageClosed,'all');
    
%     purpleBoundingBox = stats(2).BoundingBox;
%     purple_cropped_image = imcrop(im_orig, purpleBoundingBox);
%     [color] = identifyColor(purple_cropped_image);
%     disp(color);

%     orangeBoundingBox = stats(5).BoundingBox;
%     orange_cropped_image = imcrop(im_orig, orangeBoundingBox);
%     [color] = identifyColor(orange_cropped_image);
%     disp(color);

% 
%     greenBoundingBox = stats(11).BoundingBox;
%     green_cropped_image = imcrop(im_orig, greenBoundingBox);
%     [color] = identifyColor(green_cropped_image);
%     disp(color);

    for idx = 2:size(stats)
        boundingBox = stats(idx).BoundingBox;
        cropped_image = imcrop(im_orig, boundingBox);
        [color] = identifyColor(cropped_image);
        figure;
        imshow(cropped_image);
        title(color);
    end
end


function [color] = identifyColor(imageArray)
%    figure
%    imshow(imageArray);
   %Convert into the color space
   %Run regionprop
   %If we find connecting regions inside
   %Then we have found our color
   %Find our predefined color space
   background = [0.5639 8.5682; -0.2781 0.7569; 1.8178 8.4971];
   magic_threshold = 500000;
   purple_lab = [ 45.8924 -37.0724   ;46.5516 -37.0963 ; 46.7916 -38.3702];
   orange_lab = [63.0793 63.5914 ; 62.6534 64.6417; 61.9231 63.8962];
   green_lab = [-60.7539 35.3522; -61.1756 36.2021; -59.0042 36.1803];
   imageToLab = rgb2lab(imageArray);

   im_a = imageToLab(:,:,2);
   im_b = imageToLab(:,:,3);
   im_ab =[ im_a(:) im_b(:) ];
   se = strel("disk", 8);

   %Purple color space
   mahal_to_purple = ( mahal( im_ab, purple_lab ) ) .^(1/2);
   mahal_to_background = ( mahal( im_ab, background ) ) .^(1/2);
   class_0  = mahal_to_purple < mahal_to_background;
   purple_im  = reshape( class_0, size(im_a,1), size(im_a,2) );
   purple_opened = imopen(purple_im, se);
   purple_closed = imclose(purple_opened,se);
%    figure;
%    imshow(purple_closed);
   %Run region props and then see if we have a lot of regions
   purple_stats = regionprops(purple_closed,'all');
   if (min(size(purple_stats)) > 0)
        color = "purple";
        return
   end


   %Check in the orange color space

   mahal_to_orange = ( mahal( im_ab, orange_lab ) ) .^(1/2);
   mahal_to_background = ( mahal( im_ab, background ) ) .^(1/2);
   class_0  = mahal_to_orange < mahal_to_background;
   orange_im  = reshape( class_0, size(im_a,1), size(im_a,2) );
   orange_opened = imopen(orange_im, se);
   orange_closed = imclose(orange_opened,se);
%    figure;
%    imshow(orange_closed);
   orange_stats = regionprops(orange_closed,'all');
   if (min(size(orange_stats)) > 0)
        color = "orange";
        return
   end

   %Check in green color space
   mahal_to_green = ( mahal( im_ab, green_lab ) ) .^(1/2);
   mahal_to_background = ( mahal( im_ab, background ) ) .^(1/2);
   class_0  = mahal_to_green < mahal_to_background;
   green_im  = reshape( class_0, size(im_a,1), size(im_a,2) );
   green_opened = imopen(green_im, se);
   green_closed = imclose(green_opened,se);
%    figure;
%    imshow(green_closed);
   green_stats = regionprops(green_closed, 'all');
   if (min(size(green_stats)) > 0)
        color = "green";
        return
   end
    
end

