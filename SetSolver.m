function SetSolver(fileName)
    fileName = "IMG_7542.jpg"
    defineBlackBoxes(fileName)
end

function defineBlackBoxes(fileName)
    image_in = "IMG_7542.jpg";
    im_orig = imread(image_in);
    grayscaleImage = rgb2gray(im_orig);
    figure
    imshow(grayscaleImage);
    bwImage = im2bw(grayscaleImage,.3);
    figure
    imshow(bwImage)
    se = strel("disk", 8);
    bwImageOpened = imopen(bwImage, se);
    bwImageClosed = imclose(bwImageOpened,se);
    figure
    imshow(bwImageClosed)
    stats = regionprops(bwImageClosed,'all');
    allBoundingBox = stats(:).BoundingBox;
end

