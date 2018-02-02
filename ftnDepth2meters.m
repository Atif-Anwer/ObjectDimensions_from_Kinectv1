%% 
% This function converts depth values read from the depth image to  
% millimeters and outputs an image with the values. 
% -----------------------------------
% NOTE: 
% While Interpreting Sensor Values, note that The raw sensor values 
% returned by the Kinect's depth sensor are not directly proportional to the depth. 
% Instead, they scale with the inverse of the depth. 
% This means:
%       val_millimeters(x,y) (<Scale>) 1 / ( depthImage(x,y) )
% OR, the lesser the depth or target object, the higher the value of depth
% in the depth image. So Simple grayscale (or im2uint8 ) will NOT work. 
% ------------------------------------
% NOTE 2: 
% (http://msdn.microsoft.com/en-us/library/jj131028.aspx)
% Packed depth information - Each depth pixel is represented by one 16-bit value. 
% The 13 high-order bits contain the depth value; the 3 low-order bits contain the player index. 
% Any depth value outside the reliable range is replaced with a special value to indicate 
% that it was too near, too far, or unknown.
% 
%     Too near: 0x0000
%     Too far: 0x7ff8
%     Unknown: 0xfff8
% ------------------------------------
% Therefore:
% 1. We need Values from first 11 bits (and not uint16). 
%    2^11 = 2048 ;  therefore values will range from 0-2047
% 2. Then we need to convert these values to meaningful depth values to
%    meters using scaling coefficients. People have done relatively accurate studies  
%    to determine these coefficients 
%    with high accuracy, see the ROS kinect_node page and work by Nicolas Burrus. 
% -------------------------------------
% For Bitwise operation:
% (0011 1111 1111 1000)b = (16376)d = (7FF8)h
% 
% Code:-
% A = bitand(img(x,y),32760,'uint16')
% B = bitshift(A,1)
% B = bitshift(B,-3)
% 
% 0011 0011 0011 1010 = 13114 (orig No)
% 0011 0011 0011 1000 = 13112 (bitwise AND to remove last 3
% 0110 0110 0111 0000 = 26224 (bitshift left to remove MSB)
% 0000 1100 1100 1110 = 3278  (bitshift right to get Correncted Decimal Value)  

%%
function [ depthImgmeters ] = ftnDepth2meters( depthImage )

% depthImage = imread('depth.png')
[row,col] = size(depthImage);

%pre-assigning matrix
depthImgmeters = double(depthImage)/5000.0;

% for x=1 : row;
%     for y=1 : col;
%         % Get depth value
%         X = depthImage(x,y); 
%         % Removing last 3 bits (Player index)           <- 16 bit data
%         A = bitand(X,16376,'uint16');
%         % bitshift left to remove MSB                   <- 13 bit data
% %         Q = bitshift(A,1);
%         % bitshift right to get corrected decimal value <- 12 bit data
%         % BUT to convert to 11 bit depth data, shift LSB by one more
%         % so data lost is minimum                       <-     11 bit data
%         Q = bitshift(A,-3);
%         % The frieburg dataset depth images are scaled by a factor of 5000,
%         % i.e., a pixel value of 5000 in the depth image corresponds to a 
%         % distance of 1 meter from the camera (instead of 1mm = 1000m), 
%         % 10000 to 2 meter distance etc. 
%         % Therefore, to get the actual depth data, the freiburg depth
%         % images need to be divided by 5000 to get the actual depth value
%         % for each pixel.
%         % Also 5000 pixel val is 1m, so multiply by 1000 to get values in mm
%         % (OR x*1000/5000 ~= depth*1/5) .
%         depthImgMillimeters(x,y) = double(Q)/1.0;
%     end
% end

end

