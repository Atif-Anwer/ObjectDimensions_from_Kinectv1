% Function to calculate the Dynamic Depth Resolution. takes depth image as
% input (with 11-bit data in meters extracted from Kinects 16-bit
% depth data). Outputs two corrected resoultion depth images, one for row
% resolution and one for column resolution.

function [ sizeX_mm, sizeY_mm ] = ftnCalcDepthResolution( depthImgMeters, userCol, userRow )

% ------------------- For Testing Purposes ------------------------ %
% depthImgMeters = imread('d2.png');
% % book
% userCol = [49.7892768079801;8.59226932668321;98.3428927680797;132.183291770573];
% userRow = [283.180798004987;387.644638403990;386.173316708229;278.766832917706];
% ----------------------------------------------------------------- %

global sizeX_mm;
global sizeY_mm;
global depthImgMeters;
global filledDepth;
global H_col;
global H_row;


[ImgRows,ImgCols] = size(depthImgMeters);

% ----------------------------------------------
% Note: 640x480 means 480 rows and 640 columns!
%       and size() returns in format (Row, Col)
% Note: getpts returns points in the format (Col, Rows)
% THEREFORE: 
%       userCol == Columns
%       userRow == Rows
% ----------------------------------------------

% ImgRows=ImgRows*1;
% ImgCols=ImgCols*1;

%pre-assigning matrix
% global pts;
H_col = double(depthImgMeters);
H_row = double(depthImgMeters);

%Angle of View of Kinect are specified in MSDN as 43 and 57 deg
AoV_H = 45.6*pi/180;                      % Angle of view - Horizontal
AoV_V = 58.5*pi/180;                      % Angle of view - Vertical

% AoV_H = 43*pi/180;                      % Angle of view - Horizontal
% AoV_V = 57*pi/180;                      % Angle of view - Vertical
% ----------- calculating pixel resolutions in mm ------------
for row = 1 : ImgRows;
    for col = 1 : ImgCols;
        res_row = (2.0 * depthImgMeters(row,col) * tan((AoV_V)/2.0))/ImgRows;
        res_col = (2.0 * depthImgMeters(row,col) * tan((AoV_H)/2.0))/ImgCols; 
        
        H_row(row,col) = res_row;
%         H_col(row,col) = res_col;
		% THEORY: 	Since image is not a square; and since there is a kind of image 
		% 			morphing; we can compensate for the scale/morph by adding 
		% 			[ half of 1-(image ratio) ] , where image ratio is the 
		%			standard column/row ratio of images.
        H_col(row,col) = res_col + ((res_row*(abs(1-(ImgCols/ImgRows))))/2);
    end
end

% Getting points entered by user:
[ImgRows,~] = size(userCol);                  % as no of userX == userY
pts = zeros(ImgRows,2);

% length in pixels 
% x21 = (x2-x1) and so on ...
x21 = (userCol(2)- userCol(1)) ; y21 = (userRow(2)-userRow(1));
x32 = (userCol(3)- userCol(2)) ; y32 = (userRow(3)-userRow(2));
x43 = (userCol(4)- userCol(3)) ; y43 = (userRow(4)-userRow(3));
x14 = (userCol(1)- userCol(4)) ; y14 = (userRow(1)-userRow(4));

% Calculating resolution:
% Using thw The two-point form of a line in the Cartesian plane passing 
% through the points (x1,y1) and (x2,y2) : 
% y-y1=[(y2-y1)/(x2-x1)]*(x-x1)

MMx = 0.0;
MMy = 0.0;
slope = double(x21)/double(y21);

% assuming polygon from first two points;
for q = userCol(1)+4 : userCol(4)+4         %x41
    newX = round(userRow(1) + (slope * double(q - userCol(1))));
    MMx = MMx + H_col(newX,q);
end

for q = userRow(1) : userRow(2)         %y21
    newY = round(userCol(1) + (slope * double(q - userRow(1))));
    MMy = MMy + H_row(q,newY);
end

% [~,MMx] = cart2pol(x21,y21);
% [~,MMy] = cart2pol(x32,y32);



% return size of objects
sizeY_mm = MMx;
sizeX_mm = MMy;

pause(0.1);
end

% X = imread('depth.png'); ftnDepthResolution(X); imshow(H_col)

% for x=1: row
%     pt(x,1) = (userX(x,1)) ;     
%     pt(x,2) = (userY(x,1));      
% end

