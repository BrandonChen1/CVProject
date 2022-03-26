function SetSolver(fileName)
    fileName = "~/Images/IMG_7534.jpg"
    defineBlackBoxes(fileName)
end

function defineBlackBoxes(fileName)
    image_in = "Images/IMG_7666.jpg";
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
    for idx = 1:size(stats)
        boundingBox = stats(idx).BoundingBox;
%         cropped_image = imcrop(im_orig, boundingBox);
        hold on 
        rectangle('Position', [boundingBox(1), boundingBox(2), boundingBox(3), boundingBox(4)] , 'Edgecolor' , 'c', 'LineWidth', 2);

        %figure;
        %imshow(cropped_image);
    end
end

