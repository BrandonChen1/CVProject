function SetSolver(fileName)
    fileName = "~/Images/IMG_7534.jpg"
    defineBlackBoxes(fileName)
end

function defineBlackBoxes(fileName)
    image_in = "~/Images/IMG_7534.jpg";
    im_orig = imread(image_in);
    grayscaleImage = rgb2gray(im_orig);
    %figure
    %imshow(grayscaleImage);
    bwImage = im2bw(grayscaleImage,.3);
    %figure
    %imshow(bwImage)
    se = strel("disk", 8);
    bwImageOpened = imopen(bwImage, se);
    bwImageClosed = imclose(bwImageOpened,se);
    figure
    imshow(bwImageClosed)
    stats = regionprops(bwImageClosed,'all');
    for idx = 1:size(stats)
        boundingBox = stats(idx).BoundingBox;
        cropped_image = imcrop(im_orig, boundingBox);
        figure;
        imshow(cropped_image);
    end
end

