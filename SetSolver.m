function SetSolver(fileName)
    fileName = "~/Images/IMG_7534.jpg";
    defineBlackBoxes(fileName)
end

function defineBlackBoxes(fileName)
%     hist match to 7542
    image_in = "Images/IMG_7542.jpg";
    non_blurry = "Images/IMG_7542.jpg";
    non_blurry_im = imread(non_blurry);
    im_orig = imread(image_in);
    im_orig = imhistmatch(im_orig, non_blurry_im);
    padvalue = 0; % or 1 if image is single, double, or logical.
    im_orig = padarray(im_orig, [20,20],255);
    grayscaleImage = rgb2gray(im_orig);
    bwImage = im2bw(grayscaleImage,.3);
    se = strel("disk", 20);
    bwImageOpened = imopen(bwImage, se);
    bwImageClosed = imclose(bwImageOpened,se);
    stats = regionprops(bwImageClosed,'all');

    % store the images in an array that is not sorted
    % structure is {Image}
    col1 = {};
    col2 = {};
    col3 = {};
    col4 = {};
    bb1 = {};
    bb2 = {};
    bb3 = {};
    bb4 = {};
    
    % Used to look at each individual card
    for idx = 2:size(stats)
        boundingBox = stats(idx).BoundingBox;
        cropped_image = imcrop(im_orig, boundingBox);
        if (idx < 5)
            bb1 = [bb1;num2cell(boundingBox)];
            col1 = [col1;cropped_image];
        elseif (idx < 8)
            bb2 = [bb2;num2cell(boundingBox)];
            col2 = [col2;cropped_image];
        elseif (idx < 11)
            bb3 = [bb3;num2cell(boundingBox)];
            col3 = [col3;cropped_image];
        else
            bb4 = [bb4;num2cell(boundingBox)];
            col4 = [col4;cropped_image];
        end
        
%         hold on 
%         rectangle('Position', [boundingBox(1), boundingBox(2), boundingBox(3), boundingBox(4)] , 'Edgecolor' , 'c', 'LineWidth', 2);
        
%         pause(2);
    end
    
    % This is to sort the rows and cols of the cards
    [bb1, idx] = sortrows(bb1, 2);
    col1 = col1(idx);
    [bb2, idx] = sortrows(bb2, 2);
    col2 = col2(idx);
    [bb3, idx] = sortrows(bb3, 2);
    col3 = col3(idx);
    [bb4, idx] = sortrows(bb4, 2);
    col4 = col4(idx);

    % combine the cards into an array representing the original image
    cards = [col1 col2 col3 col4];
    for row = 1: size(cards,1)
        for col = 1: size(cards, 2)
            card = cards{row, col};
            [color] = identifyColorTemp(card);
            figure;
            imshow(card);
            formattedTitle = sprintf('%s', color);
            title(formattedTitle);
            pause(2);
        end
    end
    cardArray = [col1 col2 col3 col4];
    
    % create a color cell array that represents the colors for each card
    % this is where we can create all the different arrays
    % color array
    colorArray = {};
    % shade array
    shadeArray = {};
    % shape array
    shapeArray = {};
    % number array
    numberArray = {};
    
    % loop through all of the cards and call the different helper functions
    % to separate the properties
%     for row = 1: size(cardArray,1)
%         colorRow = {};
%         for col = 1: size(cardArray, 2)
%             % get the card
%             card = cardArray{row, col};
%             % get the color of the card
%             [color] = identifyColor(card);
%             % put the color into a temp row
%             colorRow = [colorRow color];
%         end
%         colorArray = [colorArray; colorRow];
%     end
%     testingCard = cards{2,1};
%     [color] = identifyColorTemp(testingCard);
%     figure;
%     imshow(testingCard);
%     formattedTitle = sprintf('%s : %d', color, number);
%     title(formattedTitle);
%     pause(2);
end

function [color] = identifyColorTemp(imageArray)
    grayscaleImage = rgb2gray(imageArray);
    bwImage = im2bw(grayscaleImage,.9);
    bwImage = padarray(bwImage, [20,20],0);
    se = strel("disk", 3);
    bwImage = imopen(bwImage, se);
    bwImage = ~bwImage;
    stats = regionprops(bwImage,'all');
    color = '';
    for i=2:size(stats)
        if (stats(i).Area < 10000)
            continue;
        end
        boundingBox = stats(i).BoundingBox;
%         boundingBox(1) = boundingBox(1)+ 20;
%         boundingBox(2) = boundingBox(2)+ 20;
        cropped_image = imcrop(imageArray, boundingBox);
%         figure;
%         imshow(cropped_image);
        [color] = identifyColor(cropped_image);
    end

end

function 

% returns what color the image is
% imageArray is the image
function [color] = identifyColor(imageArray)
%    figure;
%    imshow(imageArray);
   %Convert into the color space
   %Run regionprop
   %If we find connecting regions inside
   %Then we have found our color
%    %Find our predefined color space
  background = [0.5639 8.5682;
       -0.2781 0.7569;
       1.8178 8.4971;
       -0.8011 0.5726;
       3.1358 17.8961;
       -0.9402 0.9511;
        ];
   purple_lab = [40.4634 -33.7511;
         42.0647 -35.1276;
         36.6729 -31.4681;
         50.7837 -40.7362;
         45.8924 -37.0724;
         48.1490 -40.2425;];
   orange_lab = [63.0793 63.5914;
       62.6534 64.6417;
       61.9231 63.8962;
       ];
   green_lab = [-60.7539 35.3522;
       -61.1756 36.2021;
       -59.0042 36.1803];
    purple_background = [
       background; green_lab 
    ];
%     background = [
%         71.3042 3.2443 9.7993;
%         70.5637 3.2555 9.8216;
%         0.6861 -0.6621 0.1942;
%         0.9207 -0.9402 0.9511;
%         76.2259 0.5944 8.7283;
%         80.1215 3.4427 8.5465;
%         1.1949 -0.9402 0.9511;
%         83.0544 2.1295 7.4591;
%         ];
% 
%     purple_lab = [
%         24.9623 40.4634 -33.7511;
%         27.6482 42.0647 -35.1276;
%         19.1517 36.6729 -31.4681;
%         36.3797 50.7837 -40.7362;
%         34.5143 45.8924 -37.0724;
%         29.1270 48.1490 -40.2425;
%         ];

   imageToLab = rgb2lab(imageArray);

%    im_l = imageToLab(:,:,1);
   im_a = imageToLab(:,:,2);
   im_b = imageToLab(:,:,3);
   im_ab =[ im_a(:) im_b(:) ];
   se = strel("disk", 3);


      %Check in the orange color space
   mahal_to_orange = ( mahal( im_ab, orange_lab ) ) .^(1/2);
   mahal_to_orange_resized = reshape(mahal_to_orange,size(im_a,1), size(im_a,2));

%    mahal_to_background = ( mahal( im_ab, background ) ) .^(1/2);
%    class_0  = mahal_to_orange < mahal_to_background;
%    orange_im  = reshape( class_0, size(im_a,1), size(im_a,2) );
%    idx = orange_im == 1;
%    orange_foreground = sum(idx(:))

%    orange_opened = imopen(orange_im, se);
%    orange_closed = imclose(orange_opened,se);
%    figure;
%    imshow(orange_closed);
%    orange_stats = regionprops(orange_im,'all');
% %    size(orange_stats)
%    if (min(size(orange_stats)) > 0)
%         color = "orange";
%         number = max(size(orange_stats));
%         return
%    end

   %Purple color space
   mahal_to_purple = ( mahal( im_ab, purple_lab ) ) .^(1/2);
   mahal_to_purple_resized = reshape(mahal_to_purple,size(im_a,1), size(im_a,2));

%    mahal_to_background = ( mahal( im_ab, background ) ) .^(1/2);
%    class_0  = mahal_to_purple < mahal_to_background;
% %    purple_im  = reshape( class_0, size(im_a,1), size(im_a,2) );
%    idx = purple_im == 1;
%    figure;
%    imshow(~idx);
%    purple_foreground = sum(idx(:))
%    purple_opened = imopen(purple_im, se);
%    purple_closed = imclose(purple_opened,se);
%    figure;
%    imshow(purple_opened);
%    %Run region props and then see if we have a lot of regions
%    purple_stats = regionprops(purple_opened,'all');
%    if (min(size(purple_stats)) > 0)
%         color = "purple";
%         number = max(size(purple_stats));
%         return
%    end


   %Check in green color space
   mahal_to_green = ( mahal( im_ab, green_lab ) ) .^(1/2);
   mahal_to_green_resized = reshape(mahal_to_green,size(im_a,1), size(im_a,2));
%    mahal_to_background = ( mahal( im_ab, background ) ) .^(1/2);
%    class_0  = mahal_to_green < mahal_to_background;
%    green_im  = reshape( class_0, size(im_a,1), size(im_a,2) );
%    idx = green_im == 1;
%    figure;
%    imshow(idx);
%    green_foreground = sum(idx(:))
%    green_opened = imopen(green_im, se);
%    green_closed = imclose(green_opened,se);
%    figure;
%    imshow(green_im);
%    green_stats = regionprops(green_im, 'all');
%    if (min(size(green_stats)) > 0)
%         color = "green";
%         number = max(size(green_stats));
%         return
%    end
%    color = "Not found";
%    number = 199999;


    color_pixel_count_array = [0 0 0];
    dim_size = size(im_a);
    for row = 1:dim_size(1)
        for col = 1:dim_size(2)
            orange_dist = mahal_to_orange_resized(row,col);
            purple_dist = mahal_to_purple_resized(row,col);
            green_dist = mahal_to_green_resized(row,col);
            
            color_array_inside = [orange_dist purple_dist green_dist];
            if (min(color_array_inside) == color_array_inside(1))
                color_pixel_count_array(1) = color_pixel_count_array(1) + 1;
            elseif (min(color_array_inside) == color_array_inside(2))
                color_pixel_count_array(2) = color_pixel_count_array(2) + 1;
            else
                color_pixel_count_array(3) = color_pixel_count_array(3) + 1;
            end
        end
    end 
    color_pixel_count_array
    if (max(color_pixel_count_array) == color_pixel_count_array(1))
        color = "Orange";
    elseif (max(color_pixel_count_array) == color_pixel_count_array(2))
        color = "Purple";
    else
        color = "Green";
    end
end

