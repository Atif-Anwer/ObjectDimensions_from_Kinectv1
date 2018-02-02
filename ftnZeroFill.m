%% Fills in all '0' depth values in an RGB-D depth image (16-bit png) from Kinect with 
% statistical mode of surrounding 25 values. 
% The code is a matlab version of the algorithm/code suggested 
% here: http://www.codeproject.com/Articles/317974/KinectDepthSmoothing
% ----------------------------------------------------------------------
% Function Input: RGB-D depth image (16-bit png)
% Function Output: depth image with all zero valued elements replaced with
% statistical mode of the surrounding 25 pixels , Number of zero pixels 
% detected in the image
% ----------------------------------------------------------------------

function [filledDepth, zeroPixels] = ftnZeroFill (depthImage)

    [row,col] = size(depthImage);
    widthBound = row-1;
    heightBound = col-1;

    % initializing output image
    filledDepth = depthImage;

    %initializing
    filterBlock5x5 = zeros(5,5);
    % to keep count of zero pixels found

    zeroPixels = 0;
    for x=1 : row
        for y=1 : col        
            %Only for pixels with 0 depth value; else skip
            if filledDepth(x,y) == 0;
                zeroPixels = zeroPixels+1;
                % values set to identify a positive filter result.
                 p = 1;
                 % Taking a cube of 5x5 around the 0 depth pixel
                for xi = -2 : 1 : 2;
                    % q index max 5
                    q = 1;
                    for yi = -2 : 1 : 2;

                        % avoiding the center pixel of the 5x5 block ; its already zero!
    %                     if(xi ~= 0 && yi ~= 0)
                            % updating index for next pass
                            xSearch = x + xi; 
                            ySearch = y + yi;
                            % xSearch and ySearch to avoid edges
                            if (xSearch > 0 && xSearch < widthBound && ySearch > 0 && ySearch < heightBound)
                                % save values from depth image into filter
    %                             if (xi>=0 && yi >=0)
                                    % save values to filter block
                                    filterBlock5x5(p,q) = filledDepth(xSearch,ySearch);
    %                             end
                            end
    %                     end
                        q = q+1;
                    end
                    p = p+1;
                end

                % Calculating statistical mode of the 5x5 matrix
                X = sort(filterBlock5x5(:));
                % find all non-zero entries in the sorted filter block 
                [~,~,v] = find(X);
                % indices where repeated values change
                if (isempty(v));
                    filledDepth(x,y) = 0;
                else
                    indices   =  find(diff([v; realmax]) > 0);
                    % longest persistence length of repeated values
                    [modeL,i] =  max (diff([0; indices]));     
                    mode      =  v(indices(i));

                    % fill in the x,y value with the statistical mode of the values
                    filledDepth(x,y) = mode;
                end
            end
        end
    % end for
    end

    % filledDepth successfully modified ;  all zero values filled ?;

%     zeroPixels
return;

end


