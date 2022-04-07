function SetSolver(fileName)
    fileName = "~/Images/IMG_7534.jpg";
    defineBlackBoxes(fileName)
end

function defineBlackBoxes(fileName)
%     hist match to 7542
    image_in = "Images/IMG_7649.jpg";
    non_blurry = "Images/IMG_7545.jpg";
    non_blurry_im = imread(non_blurry);
    im_orig = imread(image_in);
    figure;imshow(im_orig);
    im_orig_matched = imhistmatch(im_orig, non_blurry_im, 'Method', 'polynomial');
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
        %create bounding boxes with the histogram match
%         cropped_image = imcrop(im_orig, boundingBox);
        cropped_image = imcrop(im_orig_matched, boundingBox);
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
%     for row = 1: size(cards,1)
%         for col = 1: size(cards, 2)
%             card = cards{row, col};
%             [color] = identifyColorTemp(card);
%             figure;
%             imshow(card);
%             formattedTitle = sprintf('%s', color);
%             title(formattedTitle);
%             pause(3);
%         end
%     end

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
    for row = 1: size(cardArray,1)
        colorRow = {};
        for col = 1: size(cardArray, 2)
            % get the card
            card = cardArray{row, col};
            % get the color of the card
            [color] = identifyColorTemp(card);
            % put the color into a temp row
            colorRow = [colorRow color];
        end
        colorArray = [colorArray; colorRow];
    end
    colorArray
%     testingCard = cards{3,4};
%     [color] = identifyColorTemp(testingCard);
%     figure;
%     imshow(testingCard);
%     formattedTitle = sprintf('%s : %d', color, number);
%     title(formattedTitle);
%     pause(2);
end

function [color] = identifyColorTemp(imageArray)
    figure; imshow(imageArray);
    grayscaleImage = rgb2gray(imageArray);
    bwImage = im2bw(grayscaleImage, .8);
    bwImage = padarray(bwImage, [20,20],0);
    se = strel("disk", 3);
    bwImage = imopen(bwImage, se);
    bwImage = ~bwImage;
    stats = regionprops(bwImage,'all');
    color = '';
    for i=2:size(stats)
        if (stats(i).Area < 1000)
            continue;
        end
        boundingBox = stats(i).BoundingBox;
%         boundingBox(1) = boundingBox(1)+ 20;
%         boundingBox(2) = boundingBox(2)+ 20;
        cropped_image = imcrop(imageArray, boundingBox);
%         figure;
%         imshow(cropped_image);
        [color] = identifyColorRange(cropped_image);
        color
    end

end

function [color] = identifyColorRange(imageArray)
   imageToLab = rgb2lab(imageArray);
   im_a = imageToLab(:,:,2);
   im_b = imageToLab(:,:,3);
   color_pixel_count_array = [0 0 0];
   test = zeros(size(imageArray, 1), size(imageArray, 2));
   dim_size = size(im_a);
   for row = 1:dim_size(1)
       for col = 1:dim_size(2)
            a_val = im_a(row, col);
            b_val = im_b(row, col);
            % black or white
            if abs(a_val) < 10 || abs(b_val) < 10
                continue;
            % orange
            elseif a_val > 0 && b_val > 0
                test(row, col) = 1;
                color_pixel_count_array(1) = color_pixel_count_array(1) + 1;
            % purple
            elseif a_val > 0 && b_val < 0
%                 [a_val, b_val]
                color_pixel_count_array(2) = color_pixel_count_array(2) + 1;
            % green
            elseif a_val < 0 && b_val > 0
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
