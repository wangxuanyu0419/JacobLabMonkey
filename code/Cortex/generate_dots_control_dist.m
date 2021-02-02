%GENERATE_DOTS_CONTROL_DIST   Control dot patterns (distractors).
%   GENERATE_DOTS_CONTROL_DIST generates dot patterns with summed area and 
%   mean distance between dots fixed.
%   Patterns can be generated with variable dot colors (for the distractor
%   stimuli).

%   Simon Jacob, 27.09.2011

clear;
colordef none;

winsize_x = 270;
winsize_y = 270;
pos = [400, 400, winsize_x, winsize_y]; 
set(gcf,'Position',pos)

% circle generation
t = (0:2*pi/200:2*pi);
x = sin(t);
y = cos(t);

% background circle
xbig = 5;                   % center  
ybig = 5;
radiusbig = 5;              % radius
backcolor = [0.2 0.2 0.2];  % color

% numerosity ranges
minnumber = 1;
maxnumber = 4;

% dots
minradius = 0.35;
maxradius = 0.53;

% distance(density) ranges
%maxDistance = 3.15; % high density 
%minDistance = 3.13; % high density
maxDistance = 5.03; % low density 
minDistance = 5.0; % low density

% minimum distance of dots to border of background circle
distanceToBorder = 0.4;
% minimum distance of dots to other dots
mindist = 0.2;

% DISTRACTORS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% dot color
dotcolor = [0.2 0.2 0.2];
% number of different images per numerosity
images = 25;

for number = minnumber:maxnumber
    
    xpos = zeros(number,1);
    ypos = zeros(number,1);
    radius = zeros(number,1);
  
    i = 1;
    while i <= images
        % background circle
        fill(x*radiusbig+xbig, y*radiusbig+xbig, backcolor);
        hold on;
        axis([0 10 0 10])
        axis square off
      
        % dots
        temp_area = zeros(number,1);
        if number == 1
            temp_area = 1.0;
        else
            for j = 1:number
                % choose a random radius between minradius and maxradius
                temp = minradius + (maxradius - minradius)*rand;
                temp_area(j) = temp*temp; 
            end  

            % ensure summed area = 1.0
            % change area of last dot if necessary
            if sum(temp_area) ~= 1.0
                diff = 1.0 - sum(temp_area);
                temp_area(j) = temp_area(j) + diff;
            end
        end % else (more than one dot)
       
        distance_fit = 0;
        trials_dist = 0;      
        while distance_fit == 0
            trials_dist = trials_dist+1;  
            if trials_dist > 1000000
                error('Could not equate distance!');
            end 
                
            % determine dot positions
            for j=1:number
                tempradius = sqrt(abs(temp_area(j)));
              
                position_fit = 0;
                trials_pos = 0;
                while position_fit == 0 
                    trials_pos = trials_pos+1;  
                    if trials_pos > 1000
                          error('Could not determine dot position!');
                    end
                  
                    % choose a random position 
                    tempmin = xbig-radiusbig;
                    tempmax = xbig+radiusbig;
                    tempx = tempmin + (tempmax-tempmin)*rand;
                    tempmin = ybig-radiusbig;
                    tempmax = ybig+radiusbig;
                    tempy = tempmin + (tempmax-tempmin)*rand;

                    % if circle is not inside background circle, discard position           
                    if inside(tempx,tempy,xbig,ybig,tempradius,radiusbig,distanceToBorder) == 0 
                        continue;
                    end
                  
                    % test overlap with any of the previous circles    
                    temp_overlap = 0;
                    for k=1:j-1
                        if overlap(tempx,tempy,xpos(k),ypos(k),tempradius,radius(k),mindist) == 1 
                            % position must be discarded
                            temp_overlap = 1;
                            break;
                        end
                    end
                    
                    % test overlap with fixation spot
                    if overlap(tempx,tempy, xbig, ybig, tempradius, 0.3, mindist) == 1
                        temp_overlap = 1;
                    end
                  
                    if temp_overlap
                        continue;
                    else
                        % no overlap, good position          
                        position_fit = 1;   
                    end
                end       
                % save position
                xpos(j) = tempx;
                ypos(j) = tempy;
                radius(j) = tempradius;
            end % for j (number)                  

            if number ~= 1
            	% calculate mean distance
                distance_fit = 0;
                index = 1;
                temp = 2;
                for p1 = 1:number-1    
                    for p2 = temp:number
                        distance(index) = sqrt((xpos(p1)-xpos(p2))^2+(ypos(p1)-ypos(p2))^2);                                
                        index = index + 1;
                    end
                    temp = temp + 1;
                end
                index = index - 1;    % correct for last increment in for loop      
                meanDistance = sum(distance)/index;
                if meanDistance < maxDistance && meanDistance > minDistance
                    distance_fit = 1;  
                end
            else
                distance_fit = 1;
            end
            
        end % while (distance) 
      
        % draw dots
        for j=1:number
            fill(x*radius(j) + xpos(j),y*radius(j) + ypos(j), dotcolor, 'EdgeColor', dotcolor);
            hold on
        end    

        % capture frame and convert to indexed color
        F = getframe;
        [img, cmap] = frame2im(F);
        [img, cmap] = rgb2ind(img, 256);
        filename = strcat(num2str(400+100*number+75+i),'.bmp')
        imwrite(img, cmap, strcat('C:\Monkey\WCortex\',filename));
        i = i+1;
        hold off;

    end % while (bilder)
end % for (dots)