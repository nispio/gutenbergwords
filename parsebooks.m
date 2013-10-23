FOLDER = 'books/words/';                % Folder containing word data
FILEEXT = '.out';                       % File extension to look for

A = uint8('A');                         % ASCII representation of A
Z = uint8('Z');                         % ASCII representation of Z
C = Z-(A-1)+1;                          % Number of characters of interest
T = ones(C,C);                          % Initialize transition count matrix

%
% Loop over all of the files in the specified folder
%
filename = ls(sprintf('%s*%s',FOLDER,FILEEXT));
for book = 1:size(filename,1)
   %
   % Open the file for reading
   %
   filepath = sprintf('%s%s',FOLDER,filename(book,:));
   fid = fopen(filepath);
   if fid > 0
       display(sprintf('Reading: "%s"', filepath));
       txt = uint8(fread(fid,Inf));
       fclose(fid);
   else
       continue;
   end

   %
   % Shift the characters down to the range 1-27
   % 
   L = mod(txt-(A-1),C)+1;

   %
   % Loop over each consecutive pair of letters
   %
   for idx = 2:length(L)
       %
       % Get the current count for this transition
       % and increment the transition count by 1
       %
       t = T(L(idx-1),L(idx));
       T(L(idx-1),L(idx)) = t + 1;
   end
end

%
% Set the arrays used for the plot labels
% 
Tick = 1:27;
tl =char(Tick.'+63);
tl(1) = char('_');
TickLabel = mat2cell(tl,length(xi),1);

%
% Plot and label the transition count matrix
%
figure(1); clf;
imagesc(log(T)); axis image;
colormap(gray(256)); colorbar;
title('Letter Transition Counts (Log Scale)','FontSize',16);
xlabel('To Letter','FontSize',14);
ylabel('From Letter','FontSize',14);
% set(gca,'XAxisLocation','top');
set(gca,'TickLength',[0 0]);
set(gca,'XTick',xi);
set(gca,'XTickLabel',TickLabel);
set(gca,'YTick',xi);
set(gca,'YTickLabel',TickLabel);
