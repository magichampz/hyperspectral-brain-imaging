% cam = webcam(2)
% preview(cam)

im = imread("test-1.jpg");

r = im(:,:,1);
g = im(:,:,2);
b = im(:,:,3);

y = 0.299*r + 0.587*g + 0.114*b;

figure
subplot(2,2,1)
imshow(r)

subplot(2,2,2)
imshow(g)

subplot(2,2,3)
imshow(b)

subplot(2,2,4)
imshow(y)