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
    figure
    imshow(bwImageClosed);
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
        %figure;
        %imshow(cropped_image);
    end
    bb1
    [bb1, idx] = sortrows(bb1, 2);
    col1 = col1(idx);
    [bb2, idx] = sortrows(bb2, 2);
    col2 = col2(idx);
    [bb3, idx] = sortrows(bb3, 2);
    col3 = col3(idx);
    [bb4, idx] = sortrows(bb4, 2);
    col4 = col4(idx);
    cards = [col1 col2 col3 col4];
    cards
    figure;
    for row = 1: size(cards,1)
        for col = 1: size(cards, 2)
            subplot(3, 4, (row-1)*4+col)
            image = cards{row,col};
            imshow(image)
        end
    end
end

