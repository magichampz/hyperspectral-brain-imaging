function Webcam
    % Check if webcam support is installed
    if ~exist('webcam', 'file')
        error('Webcam support is not available. Please install the Image Acquisition Toolbox.');
    end

    % Create a figure window
    fig = figure('Name', 'Webcam Capture', 'NumberTitle', 'off', 'CloseRequestFcn', @closeFigure);

    % Create a 'Capture' button
    btn = uicontrol('Style', 'pushbutton', 'String', 'Capture',...
                    'Position', [20, 20, 100, 40], 'Callback', @captureImage);

    % Access the webcam
    cam = webcam(2); 
    % Create an axes to display the live video
    ax = axes('Units', 'pixels', 'Position', [130, 20, 640, 480]);
    img = image(ax, zeros(480, 640, 3, 'uint8'));
    axis(ax, 'image');

    % Update the image in the axes on each frame
    t = timer('TimerFcn', @(~,~) set(img, 'CData', snapshot(cam)), 'ExecutionMode', 'fixedRate', 'Period', 0.1);
    start(t);

    % Nested function for capturing an image
    function captureImage(~, ~)
        capturedImage = snapshot(cam); % Take a snapshot with the webcam
        assignin('base', 'capturedImage', capturedImage); % Save the captured image to the base workspace
        fprintf('Image captured.\n');
    end

    % Nested function to clean up on close
    function closeFigure(~, ~)
        stop(t); % Stop the timer
        delete(t); % Delete the timer
        clear cam; % Clear the webcam object
        delete(fig); % Delete the figure window
    end
end
