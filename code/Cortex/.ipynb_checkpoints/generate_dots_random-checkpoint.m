%GENERATE_DOTS_RANDOM   Random dot patterns.
%   GENERATE_DOTS_RANDOM generates random dot patterns.
%   There are 25-1 possible positions (center is excluded) and 5 possible 
%   dot sizes.

%   Simon Jacob, 27.09.2011

clear;
colordef none;

%winsize_x = 350;   % 4.0 deg radius
%winsize_y = 350;

winsize_x = 270; 
winsize_y = 270;

backcolor = [0.2 0.2 0.2];

% dot sizes
kreis_faktor = [1.0, 0.9, 0.8, 0.7, 0.6,... 
                1.0, 0.9, 0.8, 0.7, 0.6,...  
                1.0, 0.9, 0.8, 0.7, 0.6,... 
                1.0, 0.9, 0.8, 0.7, 0.6,... 
                1.0, 0.9, 0.8, 0.7, 0.6,... 
                1.0, 0.9, 0.8, 0.7, 0.6,... 
                1.0, 0.9, 0.8, 0.7, 0.6];
            
% correction factor for dot sizes 
size1x = 0.7;
size1y = 0.7;

% dot positions (x and y)
positions = [2.2, 3.6, 5.0, 6.4, 7.8];
% dot color
dotcolor = [0.0 0.0 0.0];

pos=[400, 400, winsize_x, winsize_y]; 
set(gcf,'Position',pos);

% circle
t = (0:2*pi/200:2*pi);
x = sin(t);
y = cos(t);

% number of different images per numerosity
images = 75;

% BACKGROUND CIRCLE %%%%%%%%%%%%%%%%%

fill(x*5+5, y*5+5, backcolor);
axis([0 10 0 10])
axis square off
% capture frame and convert to indexed color
F = getframe;
[img, cmap] = frame2im(F);
[img, cmap] = rgb2ind(img, 256);
imwrite(img, cmap, strcat('C:\Monkey\WCortex\','0.bmp'));
hold off;

% 1 DOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start = 101;
i = start;
while(i<(start+images))
x_pos = shuffle(positions);
y_pos = shuffle(positions);
% exclude center position
   while(((x_pos(1)==5) && (y_pos(1)==5)) || ((x_pos(2)==5) && (y_pos(2)==5)) || ((x_pos(3)==5) && (y_pos(3)==5)) || ((x_pos(4)==5) && (y_pos(4)==5)) || ((x_pos(5)==5) && (y_pos(5)==5)) || ((x_pos(1)==5) && (y_pos(2)==5)) )
      x_pos = shuffle(positions);
      y_pos = shuffle(positions);
   end;
faktor = shuffle (kreis_faktor);

fill(x*5+5, y*5+5, backcolor);
hold on;

fill(x*size1x*faktor(1) + x_pos(1),	y*size1y*faktor(1) + y_pos(1), dotcolor);

axis([0 10 0 10])
axis square off
% capture frame and convert to indexed color
F = getframe;
[img, cmap] = frame2im(F);
[img, cmap] = rgb2ind(img, 256);
filename=strcat (num2str(i),'.bmp')
imwrite(img, cmap, strcat('C:\Monkey\WCortex\',filename));
hold off;

i= i+1;
end;

% 2 DOTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%

start = 201;
i = start;
while(i<(start+images))
x_pos = shuffle(positions);
y_pos = shuffle(positions);
% exclude center position
   while(((x_pos(1)==5) && (y_pos(1)==5)) || ((x_pos(2)==5) && (y_pos(2)==5)) || ((x_pos(3)==5) && (y_pos(3)==5)) || ((x_pos(4)==5) && (y_pos(4)==5)) || ((x_pos(5)==5) && (y_pos(5)==5)) || ((x_pos(1)==5) && (y_pos(2)==5)) )
      x_pos = shuffle(positions);
      y_pos = shuffle(positions);
   end;
faktor = shuffle (kreis_faktor);

fill(x*5+5, y*5+5, backcolor);
hold on;

fill(x*size1x*faktor(1) + x_pos(1),	y*size1y*faktor(1) + y_pos(1), dotcolor);
fill(x*size1x*faktor(2) + x_pos(2),	y*size1y*faktor(2) + y_pos(2), dotcolor);

axis([0 10 0 10])
axis square off
% capture frame and convert to indexed color
F = getframe;
[img, cmap] = frame2im(F);
[img, cmap] = rgb2ind(img, 256);
filename=strcat (num2str(i),'.bmp')
imwrite(img, cmap, strcat('C:\Monkey\WCortex\',filename));
hold off;

i= i+1;
end;

% 3 DOTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%

start = 301;
i = start;
while(i<(start+images))
x_pos = shuffle(positions);
y_pos = shuffle(positions);
% exclude center
   while(((x_pos(1)==5) && (y_pos(1)==5)) || ((x_pos(2)==5) && (y_pos(2)==5)) || ((x_pos(3)==5) && (y_pos(3)==5)) || ((x_pos(4)==5) && (y_pos(4)==5)) || ((x_pos(5)==5) && (y_pos(5)==5)) || ((x_pos(1)==5) && (y_pos(2)==5)) )
      x_pos = shuffle(positions);
      y_pos = shuffle(positions);
   end;
faktor = shuffle (kreis_faktor);

fill(x*5+5, y*5+5, backcolor);
hold on;

fill(x*size1x*faktor(1) + x_pos(1),	y*size1y*faktor(1) + y_pos(1), dotcolor);
fill(x*size1x*faktor(2) + x_pos(2),	y*size1y*faktor(2) + y_pos(2), dotcolor);
fill(x*size1x*faktor(3) + x_pos(3),	y*size1y*faktor(3) + y_pos(3), dotcolor);

axis([0 10 0 10])
axis square off
% capture frame and convert to indexed color
F = getframe;
[img, cmap] = frame2im(F);
[img, cmap] = rgb2ind(img, 256);
filename=strcat (num2str(i),'.bmp')
imwrite(img, cmap, strcat('C:\Monkey\WCortex\',filename));
hold off;

i= i+1;
end;

% 4 DOTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%

start = 401;
i = start;
while(i<(start+images))
x_pos = shuffle(positions);
y_pos = shuffle(positions);
% exclude center
   while(((x_pos(1)==5) && (y_pos(1)==5)) || ((x_pos(2)==5) && (y_pos(2)==5)) || ((x_pos(3)==5) && (y_pos(3)==5)) || ((x_pos(4)==5) && (y_pos(4)==5)) || ((x_pos(5)==5) && (y_pos(5)==5)) || ((x_pos(1)==5) && (y_pos(2)==5)) )
      x_pos = shuffle(positions);
      y_pos = shuffle(positions);
   end;
faktor = shuffle (kreis_faktor);

fill(x*5+5, y*5+5, backcolor);
hold on;

fill(x*size1x*faktor(1) + x_pos(1),	y*size1y*faktor(1) + y_pos(1), dotcolor);
fill(x*size1x*faktor(2) + x_pos(2),	y*size1y*faktor(2) + y_pos(2), dotcolor);
fill(x*size1x*faktor(3) + x_pos(3),	y*size1y*faktor(3) + y_pos(3), dotcolor);
fill(x*size1x*faktor(4) + x_pos(4),	y*size1y*faktor(4) + y_pos(4), dotcolor);

axis([0 10 0 10])
axis square off
% capture frame and convert to indexed color
F = getframe;
[img, cmap] = frame2im(F);
[img, cmap] = rgb2ind(img, 256);
filename=strcat (num2str(i),'.bmp')
imwrite(img, cmap, strcat('C:\Monkey\WCortex\',filename));
hold off;

i= i+1;
end;