% #######################################################
% Both the color & IR images of the Freiburg 3 sequences have already been  
% undistorted (i.e. Calibrated), therefore the distortion parameters are 
% all zero. So no kinect calibration is required on the dataset.
% http://nicolas.burrus.name/index.php/Research/KinectCalibration
% http://vision.in.tum.de/data/datasets/rgbd-dataset/file_formats
% ######################################################



function varargout = GUI_DepthResolution_v4(varargin)
    % GUI_DEPTHRESOLUTION_V4 MATLAB code for GUI_DepthResolution_v4.fig
    % Edit the above text to modify the response to help GUI_DepthResolution_v4

    % Last Modified by GUIDE v2.5 24-Aug-2014 17:42:45

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @GUI_DepthResolution_v4_OpeningFcn, ...
                       'gui_OutputFcn',  @GUI_DepthResolution_v4_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT
end

% --- Executes just before GUI_DepthResolution_v4 is made visible.
function GUI_DepthResolution_v4_OpeningFcn(hObject, ~, handles, varargin)
    % hObject    handle to figure

    % Choose default command line output for GUI_DepthResolution_v4
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % ################# Custom Opening Cmds ##################### %
        set(handles.btnLoadKinectData,'Enable','off');
        set(handles.btnPauseFrame,'Enable','off');
        clc;

    % #################---------------------##################### %
end

% --- Outputs from this function are returned to the command line.
function varargout = GUI_DepthResolution_v4_OutputFcn(~, ~, handles) 
    % hObject    handle to figure

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

%% ========================================================== 
% ######### ######### Edited Functions ######### #########%%
% ========================================================== 

% --- Executes on button press in btnLoadDataset.
function btnLoadDataset_Callback(~, ~, handles) %#ok<*DEFNU>
    % hObject    handle to btnLoadDataset (see GCBO)
    clc;
    global depthImgMeters;
    global img1;
    global h5;
    global h2;
    global img2;

    DatasetPath = uigetdir(pwd);                                   % Get path to dataset folder
    addpath(genpath(DatasetPath))                                  % Add Subfolder to search path
    if ~isdir(DatasetPath)
        errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
        uiwait(warndlg(errorMessage));
        return;
    end

    % --Variables--
    % DatasetPath:  Path of dataset selected by user
    % RGBpath:  Path or 'rgb' folder (assumed to be inside DatasetPath by default)
    % RGBFiles: Number of png rgb files
    % RGBpath:  Path or 'depth' folder (assumed to be inside DatasetPath by default)
    % RGBFiles: Number of png depth files

    
    RGBpath=fullfile(DatasetPath,'rgb');
    DEPTHpath=fullfile(DatasetPath,'/depth');

    % Process Files in Folder 'dataset/rgb'
    fileRGB = fullfile(RGBpath, '*.png');
    rgbFileList = dir(fileRGB);
    RGBFiles = length(rgbFileList);
    set(handles.txtRGBNumber, 'string', RGBFiles)

    % Process Files in Folder 'dataset/depth'
    fileDepth = fullfile(DEPTHpath, '*.png');
    depthFileList = dir(fileDepth);
    DepthFiles = length(depthFileList);
    set(handles.txtDepthNumber, 'string', DepthFiles)        % Display no of files 

    [h1, h2, h3, h4, h5] = createAxes();

    set(handles.btnPauseFrame,'Enable','on');

    % ... T3h L00p ...
    for i = 1:DepthFiles

        % ---------------- show rgb image ----------------
        findobj('Tag','dispRGB');
        axes(h1); 
        img1 = imread([rgbFileList(i).name]);
        imshow(img1);
        title('RGB');
        index = int2str(i);
        set(handles.text5, 'string', index)
        % Crop Image pixels each side 
        % img1 = imcrop(img1,[25 25 589 429]);

        % ---------------- show depth image ----------------
        axes(h3);
        img2 = imread([depthFileList(i).name]);
        % Crop Image pixels each side 
        % img2 = imcrop(img2,[25 25 589 429]);
        % show depth image
        imagesc(img2); 
        title('Depth');
        set(gca,'XTick',[],'YTick',[]);

        % ---------------- show depth in meters ----------------
        axes(h4);
        imagesc(depthImgMeters); 
        title('Depth to Meters');
        set(gca,'XTick',[],'YTick',[]);
        colorbar; 

        axes(h5);
%         imshow(img2); 
        
        imshowpair(img1, img2, 'falsecolor')
        
        title('Get User Input (Press Enter after selecting Object Corners)');
        set(gca,'XTick',[],'YTick',[]);
        
    end
    

end

%% ---------------------------------------------

% --- Executes on button press in btnPauseFrame.
function btnPauseFrame_Callback(hObject, ~, handles)
    % hObject    handle to btnPauseFrame (see GCBO)
    % Need to redeclare the global variables in order for them to work in
    % Matlab - (lol?!)
    global depthImgMeters;
    global filledDepth;
    global img1;
    global h5;
    global h2;
    global img2;
    global sizeX_mm;
    global sizeY_mm;
    while get(hObject,'Value')
         
        % Get user Input
%         pause(0.15);

        % ------------------ Zero Fill Image ---------------------------%
        [filledDepth, ~] = ftnZeroFill(img2);
        axes(h2);
        % show filled image    
        imshowpair(img2,filledDepth,'falsecolor');
        title('Filled');
        
        % ------------------ convert depth values to meters ------------%
        % This function converts depth values read from the depth image to  
        % meters and outputs an image with the new values. 
        depthImgMeters = ftnDepth2meters( filledDepth  );
        
        
        %  ------------------ Get vertices from user  ------------------ %
        set(gcf,'CurrentAxes',h5);
        [userCol, userRow] = getpts(gca);
        % roundoff current value to get pixels
        userCol = abs(round(userCol));
        userRow = abs(round(userRow));


        % ------------------- Display Poly ---------------------------- %
        pos = {[abs(userCol(1)),abs(userRow(1)) ...
                abs(userCol(2)),abs(userRow(2)) ...
                abs(userCol(3)),abs(userRow(3)) ...
                abs(userCol(4)),abs(userRow(4)) ...
                abs(userCol(1)),abs(userRow(1)) ...
                abs(userCol(1)),abs(userRow(1))]};
        Imr = insertShape(img1,'FilledPolygon',pos,'Color','green','Opacity',0.5);
        imshow(Imr);
        
        %  ------------------ Calculate Meters/pixel resolution  ------- %
        % Function to calculate the Dynamic Depth Resolution. takes depth 
        % image as input (with 11-bit data in millimeters extracted 
        % from Kinects 16-bit depth data). Outputs two corrected 
        % resoultion depth images, one for row resolution and 
        % one for column resolution.
        [sizeX_mm, sizeY_mm] = ftnCalcDepthResolution ( depthImgMeters, userCol, userRow );

        
        %  ------------------ Display on GUI  ------------------ %
        index = num2str(sizeX_mm,4);
        set(handles.txtSizeX, 'string', index)        % Display size
        index = num2str(sizeY_mm,4);
        set(handles.txtSizeY, 'string', index)        % Display size
        
        % Converting mm to inch %
        % 1m = 39.3701 inch %
        sizeX_mm = 39.3701*sizeX_mm;
        sizeY_mm = 39.3701*sizeY_mm;
        index = num2str(sizeX_mm,4);
        set(handles.txtSizeXin, 'string', index)        % Display size
        index = num2str(sizeY_mm,4);
        set(handles.txtSizeYin, 'string', index)        % Display size
        % --------------------- %

        sizeX_mm = 0.0;
        sizeY_mm = 0.0;

        break;
    end
end

% ========================================================== 

function [h1, h2, h3, h4, h5] = createAxes()

    % Get handles of axes in the figure
    axes(findobj('Tag','dispRGB'));                                        % Select Axes to plot
    set(gca,'XTick',[],'YTick',[]);
    title('RGB');
    h1 = gca;

    axes(findobj('Tag','dispF'));                                        % Select Axes to plot
    set(gca,'XTick',[],'YTick',[]);
    title('Filled');
    h2 = gca;

    axes(findobj('Tag','dispD'));                                        % Select Axes to plot
    set(gca,'XTick',[],'YTick',[]);
    title('Depth');
    h3 = gca;

    axes(findobj('Tag','dispFig'));                                        % Select Axes to plot
    set(gca,'XTick',[],'YTick',[]);
    title('Depth to MiliMeters');
    h4 = gca;

    axes(findobj('Tag','getUI'));                                        % Select Axes to plot
    set(gca,'XTick',[],'YTick',[]);
    title('Get User Input');
    h5 = gca;

end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
    if strcmp(selection,'No')
        return;
    end
    delete(handles.figure1)
%     clear all;
%     clear classes;
    clc;
end

function btnQuit_Callback(hObject, eventdata, handles)
    % --- Executes on button press in btnQuit.
    % Do while frame paused!
    % http://blogs.mathworks.com/videos/2010/12/03/how-to-loop-until-a-button-is-pushed-in-matlab/

    % hObject    handle to btnQuit (see GCBO)

    clc;
    figure1_CloseRequestFcn(hObject, eventdata, handles);

end
%% --------------------------------------------------------------------------

% --- Executes on button press in btnLoadKinectData.
function btnLoadKinectData_Callback(~, ~, ~)
    % hObject    handle to btnLoadKinectData (see GCBO)

    clc;
    clear;
    % close all;                                                  % close Current GUI and open new figure
    % hgload('Kinect.fig')                                       % Load figure
end


% --- Executes during object deletion, before destroying properties.
function getUI_DeleteFcn(~, ~, ~)
    % hObject    handle to getUI (see GCBO)
    % set(0,'ShowHiddenHandles','on');
    % delete(get(0,'Children'));
end

% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(~, ~, ~)
    % hObject    handle to figure1 (see GCBO)
    % C = get(figure1.handles,'CurrentPoint'),
end
