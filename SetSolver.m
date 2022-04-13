function SetSolver(fileName)
    fileName = "~/Images/IMG_7534.jpg";
    defineBlackBoxes(fileName)
end

function defineBlackBoxes(fileName)
%     hist match to 7542
    image_in = "Images/IMG_7539.jpg";
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
        numberRow = {};
        shadeRow = {};
        shapeRow = {};
        for col = 1: size(cardArray, 2)
            % get the card
            card = cardArray{row, col};
            % get the color of the card
            [color] = identifyColorTemp(card);
            [number] = identifyNumberShapes(card);
            [shade] = identifyShade(card);
            [shape] = identifyShape(card);
            % put the color into a temp row
            colorRow = [colorRow color];
            numberRow = [numberRow number];
            shadeRow = [shadeRow shade];
            shapeRow = [shapeRow shape];
        end
        colorArray = [colorArray; colorRow];
        numberArray = [numberArray; numberRow];
        shadeArray = [shadeArray; shadeRow];
        shapeArray = [shapeArray; shapeRow];
    end
    colorArray
    numberArray
    shadeArray
    shapeArray
%     testingCard = cards{3,4};
%     [color] = identifyColorTemp(testingCard);
%     figure;
%     imshow(testingCard);
%     formattedTitle = sprintf('%s : %d', color, number);
%     title(formattedTitle);
%     pause(2);
    returnSetMatrix = findSet(shapeArray, shadeArray, colorArray, numberArray);
    returnSetMatrix
end

function [color] = identifyColorTemp(imageArray)
    grayscaleImage = rgb2gray(imageArray);
    bwImage = im2bw(grayscaleImage, .8);
    bwImage = padarray(bwImage, [20,20],0);
    se = strel("disk", 3);
    bwImage = imopen(bwImage, se);
    bwImage = ~bwImage;
    stats = regionprops(bwImage,'all');
    color = '';
    color_pixel_count_array = [0 0 0];
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
        [color_pixel_count_array] = identifyColorRange(cropped_image, color_pixel_count_array);

    end
%     color_pixel_count_array
    if (max(color_pixel_count_array) == color_pixel_count_array(1))
        %Orange = 1
        color = 1;
    elseif (max(color_pixel_count_array) == color_pixel_count_array(2))
        %Purple = 2
        color = 2;
    else
        %Green
        color = 3;
    end
%     color

end

function [color_pixel_count_array] = identifyColorRange(imageArray, color_pixel_count_array)
   imageToLab = rgb2lab(imageArray);
   im_a = imageToLab(:,:,2);
   im_b = imageToLab(:,:,3);
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
end

function [number] = identifyNumberShapes(imageArray)
    grayscaleImage = rgb2gray(imageArray);
    bwImage = im2bw(grayscaleImage, .8);
    bwImage = padarray(bwImage, [20,20],0);
    se = strel("disk", 3);
    bwImage = imopen(bwImage, se);
    bwImage = ~bwImage;
    stats = regionprops(bwImage,'all');
    number = 0;
    for i=2:size(stats)
        if (stats(i).Area < 1000)
            continue;
        end
        number = number + 1;
    end
end

function [shade] = identifyShade(imageArray)
    grayscaleImage = rgb2gray(imageArray);
    bwImage = im2bw(grayscaleImage, .9);
    bwImage = padarray(bwImage, [20,20],0);
    se = strel("disk", 1);
%     bwImage = imdilate(bwImage, se);
%     bwImage = imopen(bwImage, se);
%     stats = regionprops(bwImage,'all');
%     shade = '';
%     number = 0;
%     figure; imshow(bwImage);
%     
%     for i=1:size(stats)
%         if (stats(i).Area < 1000)
%             continue;
%         end
%         number = number + 1;
%     end
%     if number == 1
%         shade = 'filled';
%     elseif number > 1 && number < 5
%         shade = 'empty';
%     else
%         shade = 'stripe';
%     end
%     shade = number;
    
    inverted = ~bwImage;
%     figure; imshow(inverted);
    stats = regionprops(inverted, 'all');
    shade = '';
    totalArea = 0;
    totalFilledArea = 0;
    for i = 2:size(stats)
        if (stats(i).Area < 1000)
            continue;
        end
        totalArea = totalArea + stats(i).Area;
        totalFilledArea = totalFilledArea + stats(i).FilledArea;
    end
%     formattedTitle = sprintf('totalArea = %d, totalFilledArea = %d', totalArea, totalFilledArea);
%     title(formattedTitle);
%     pause(5)
    ratio = totalArea/totalFilledArea;
    if ratio > .95
        %Filled = 1
        shade = 1;
    elseif ratio < .25
        %Empty = 2
        shade = 2;
    else
        %Stripe = 3
        shade = 3;
    end
end

function [shape] = identifyShape(imageArray)
    grayscaleImage = rgb2gray(imageArray);
    bwImage = im2bw(grayscaleImage, .9);
    bwImage = padarray(bwImage, [20,20],0);
    inverted = ~bwImage;
    shape = 1;
    stats = regionprops(inverted,'all');
    for index  = 2 : size(stats)
        if (stats(index).Area < 1000)
            continue;
        end
        filledImage = stats(index).FilledImage;
        edgeImage = edge(filledImage, 'canny');
        [H,T,R] = hough(edgeImage);
        P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
        lines = houghlines(edgeImage,T,R,P,'FillGap',10,'MinLength',100);
%         figure; imshow(edgeImage);
%         hold on;
%         for k = 1:length(lines)
%            xy = [lines(k).point1; lines(k).point2];
%            plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
%         
%            % Plot beginnings and ends of lines
%            plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%            plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
%         end
        if length(lines) >= 4
            %Rhombus = 1
            shape = 1;
        elseif length(lines) >= 2
            %Circle = 2
            shape = 2;
        else
            %Squiggly = 3
            shape  = 3;
        end
    end
end






function [validNum] = validNumberSet(numMatrix)
    validNum = false;
    if (numMatrix(1) == numMatrix(2)) && (numMatrix(1) == numMatrix(3) && (numMatrix(2) == numMatrix(3)))
        validNum = true;
    end
    if (numMatrix(1) ~= numMatrix(2) && numMatrix(2) ~= numMatrix(3) && numMatrix(1) ~= numMatrix(3))
        validNum = true;
    end
end

function [returnSetMatrix] = findSet(shapeArray, shadeArray, colorArray, numberArray)
    %Assume the input is a 1x12 
    shapeArray = reshape(shapeArray, 12, 1);
    shadeArray = reshape(shadeArray, 12, 1);
    colorArray = reshape(colorArray, 12, 1);
    numberArray = reshape(numberArray, 12, 1);
%     shapeArray
    returnSetMatrix = [0 0 0];
    %"1,2,3 : 3,4,7 "
    for cardOne = 1:size(shapeArray,1)
        for cardTwo = (cardOne+1):size(shapeArray,1)
            for cardThree = (cardTwo+1):size(shapeArray,1)
                    
                shapeSetArray = [shapeArray{cardOne} shapeArray{cardTwo} shapeArray{cardThree}];
                shadeSetArray = [shadeArray{cardOne} shadeArray{cardTwo} shadeArray{cardThree}];
                colorSetArray = [colorArray{cardOne} colorArray{cardTwo} colorArray{cardThree}];
                numberSetArray = [numberArray{cardOne} numberArray{cardTwo} numberArray{cardThree}];
                validShape = false;
                validShade = false;
                validColor = false;
                validNumber = false;
                validShape = validNumberSet(shapeSetArray);
                validShade = validNumberSet(shadeSetArray);
                validColor = validNumberSet(colorSetArray);
                validNumber = validNumberSet(numberSetArray);

%                 if(cardOne == 1 && cardTwo == 2 && cardThree == 6)
%                     shapeSetArray
%                     shadeSetArray
%                     colorSetArray
%                     numberSetArray
% %                     validShape 
% %                     validShade 
% %                     validColor 
% %                     validNumber 
%                     numberCondOne = numberSetArray(1) == numberSetArray(2) == numberSetArray(3)
%                     numberCondTwo = numberSetArray(1) ~= numberSetArray(2) && numberSetArray(2) ~= numberSetArray(3) && numberSetArray(1) ~= numberSetArray(3)
%                 end
                if (validShape && validShade && validColor && validNumber)
                    tempMatrix = [cardOne cardTwo cardThree];
                    returnSetMatrix = [returnSetMatrix; tempMatrix];
                end
%                 if (validShapeSet(shapeSetArray))
%                     if (validShadeSet(shadeSetArray))
%                         if(validColorSet(colorSetArray))
%                             if(validNumberSet(numberSetArray))
%                                 %This is a valid set
%                                 tempMatrix = [cardOne cardTwo cardThree];
%                                 returnSetMatrix = [returnSetMatrix; tempMatrix];
%                             end
%                         end
%                     end
%                 end
            end
        end
    end
end