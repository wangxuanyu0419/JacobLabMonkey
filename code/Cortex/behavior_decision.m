%% open CORTEX files

clear;
colordef white;

numObj    = 2;
numIntens = 8;
numColor  = 2;

[file, pathname] = uigetfile( ...
{'*.1;*.0;','CORTEX Files (*.1,*.0)';...
   '*.1', 'Training File (*.1)'; ...
   '*.0', 'Recording File (*.0)';...
   '*.*',  'All Files (*.*)'}, ...
   'Select a CORTEX file', 'C:\Data\', 'MultiSelect', 'on');

if iscell(file)
    % multiple files were selected, convert cell to string array
    file = cell2mat(file');
end

numFiles = size(file, 1);

% call Neuroexplorer
nex = actxserver('NeuroExplorer.Application');

% cycle through files
for k = 1:numFiles
    
    switch file(k,1)
        case 'M'
            Monkey   = 'Melvin';
            Obj1     = 'Cross';
            Obj2     = 'Rhomboid';
            Bright   = 12;          % monitor brightness
            Contrast = 19;          % monitor contrast
            BiasCorr = 350;         % feedback delay after releasing bar
            Stimuli = [0 10 11 12 13 16 20 22];
        case 'H'
            Monkey   = 'Harvey';
            Obj1     = 'Circle';
            Obj2     = 'Hexagon';
            Bright   = 20;
            Contrast = 30;
            BiasCorr = 210;
            Stimuli = [0 10 11 12 13 17 20 22];
    end

    Date = strcat(file(k,6:7), '.', file(k,4:5), '.', '20', file(k,2:3));
    
    % open CORTEX file
    document = nex.OpenDocument(strcat(pathname, file(k,:)));
    
    numMarkerVars = document.MarkerCount;
    
    if numMarkerVars ~= 2
        error('Incorrect number of markers (Code & Trial) in CORTEX file!');
    end
    
    %% retrieve Trial info
    
    % Start and End time
    StartTime = document.StartTime;
    EndTime = document.EndTime;
    
    % Number of trials
    Trial = document.Marker(2);
    Trial_info = Trial.MarkerValues();
    NumTrials = length(Trial_info(:,4));
    
    % Response codes (strings)
    ResponseCodes = str2num(cell2mat(Trial_info(:,6)));
    
    % Response errors (strings)
    ResponseErrors = str2num(cell2mat(Trial_info(:,7)));
    
    % close the CORTEX file
    document.Close();

    %% analyze behavior: overall performance

    % option to truncate trials
    truncate = 0;
    firstTrial = 1;
    lastTrial  = 550;

    if truncate
        ResponseCodes = ResponseCodes(firstTrial:lastTrial);
        ResponseErrors = ResponseErrors(firstTrial:lastTrial);
    end

    % include only trials with no errors (#0), missing response (#1) or
    % unexpected response (#6)
    indices = find(ResponseErrors == 0 | ResponseErrors == 1 | ResponseErrors == 6);

    adjustedNumTrials = length(indices);
    adjustedCodes = ResponseCodes(indices);
    adjustedErrors = ResponseErrors(indices);

    % Performance (% correct)
    Performance = round(length(find(adjustedErrors == 0))/adjustedNumTrials * 100);
    % Training Time (minutes)
    TrainingTime = round((EndTime - StartTime)/60);

    BinSize = 40;
    i_min = 1 + BinSize/2;
    i_max = adjustedNumTrials - 1 - BinSize/2;
    j = 1;

    onlinePerformance = zeros(1, i_max - i_min);

    for i = i_min:i_max
        correctTrials = length(find(adjustedErrors((i-BinSize/2):(i+BinSize/2)) == 0));
        onlinePerformance(j) = correctTrials/(BinSize+1) * 100;
        j = j+1;
    end

    figure('Name', ['Behavioral Performance: ', Monkey, ', ', Date, ' (', num2str(TrainingTime), ' min total)'],...
        'NumberTitle', 'off', 'Position', [200 200 800 700], 'Color', 'w'); 
    subplot(3,2,3), plot(i_min:i_max, onlinePerformance, 'Color', 'k');
    hold on;

    % plot chance level
    plot(1:adjustedNumTrials, 50.*ones(1, adjustedNumTrials), 'LineStyle', '--', 'Color', [0.8 0.8 0.8]);

    title(['Total Trials: ', num2str(adjustedNumTrials), '      Total Percent correct: ', num2str(Performance)]);
    %text(50, 25, {'Total Trials: '; num2str(adjustedNumTrials)});
    %text(200, 25,  {'Total Percent correct: '; num2str(Performance)});
    xlim([1 adjustedNumTrials]); ylim([0 100]);
    ylabel('Percent correct');
    set(gca, 'TickDir', 'out', 'Box', 'off');
    
    %% performance for individual objects and intensities
    
    performance = zeros(numIntens,numColor,numObj);
    
    % cycle through objects
    for o=1:numObj
        % cycle through intensities
        for i=1:numIntens
            % determine 'percent stimulus present' for red and blue cues
            for c=1:numColor
                if i==1
                    % no stimulus present
                    correctCode = 10000 + c*100 + 1;
                    errorCode   = 10000 + c*100;
                else
                    % stimulus present
                    correctCode = 10000 + (i-1)*1000 + c*100 + o*10 + 1;
                    errorCode   = 10000 + (i-1)*1000 + c*100 + o*10;
                end
                
                correctTrials = length(find(ResponseCodes == correctCode));
                errorTrials   = length(find(ResponseCodes == errorCode));

                if i==1
                    % no stimulus present, plot percent errors
                    performance(i,c,o) = errorTrials/(correctTrials + errorTrials) * 100;
                else
                    % stimulus present, plot correct responses
                    performance(i,c,o) = correctTrials/(correctTrials + errorTrials) * 100;
                end
            end % color
        end % intensity
    end % object

    xLabel = {num2str(Stimuli(1)), num2str(Stimuli(2)),...
              num2str(Stimuli(3)), num2str(Stimuli(4)),...
              num2str(Stimuli(5)), num2str(Stimuli(6))...
              num2str(Stimuli(7)), num2str(Stimuli(8))};

    % plot 1st object
    subplot(3,2,2), h = bar(performance(:,:,1));
    title(['Object #1 ' '(' Obj1 ')']);
    xlim([0 8.7]); set(gca, 'XTickLabel', xLabel);
    ylabel('Percent "stimulus present"');
    set(h(1), 'FaceColor', 'r'); set(h(2), 'FaceColor', 'b');
    set(gca, 'TickDir', 'out', 'Box', 'off');
    
    % plot 2nd object
    subplot(3,2,4), h = bar(performance(:,:,2));
    title(['Object #2 ' '(' Obj2 ')']);
    xlim([0 8.7]); set(gca, 'XTickLabel', xLabel);
    ylabel('Percent "stimulus present"');
    set(h(1), 'FaceColor', 'r'); set(h(2), 'FaceColor', 'b');
    set(gca, 'TickDir', 'out', 'Box', 'off');
    
    % plot mean
    % average over objects (dim 3)
    subplot(3,2,6), h = bar(mean(performance,3));
    title('Mean');
    ylabel('Percent "stimulus present"');
    xlabel('Stimulus intensity');
    xlim([0 8.7]); set(gca, 'XTickLabel', xLabel);
    set(h(1), 'FaceColor', 'r'); set(h(2), 'FaceColor', 'b');
    set(gca, 'TickDir', 'out', 'Box', 'off');

    % plot psychometric curve
    % average over objects (dim 3) and colors (dim 2)
    psycho = mean(mean(performance, 3), 2);
    subplot(3,2,5), plot(Stimuli, psycho, 'Color', 'k', 'Marker', '.', 'MarkerSize', 18);
    title('Performance');
    ylabel('Percent "stimulus present"');
    ylim([0 100]);
    xlabel('Stimulus intensity');
    set(gca, 'TickDir', 'out', 'Box', 'off');
    
    txt = annotation('textbox', [0.12 0.71 0.3 0.2]);
    set(txt, 'String', {[Monkey ', ' Date],'','',...
                        ['Brightness: ' num2str(Bright)], ['Contrast: ' num2str(Contrast)],'',...
                        ['Bias correction: ' num2str(BiasCorr) ' ms']});
                    
    set(txt, 'EdgeColor', 'none');
 
    % export figure to image file
    exportFile = strcat(pathname, file(k,1:7), '.jpg');
    print('-djpeg', exportFile);
end % files