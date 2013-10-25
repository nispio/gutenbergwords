function M = parsebooks(folder, name)

A = uint8('A');                         % ASCII representation of A
Z = uint8('Z');                         % ASCII representation of Z
C = Z-(A-1)+1;                          % Number of characters of interest
T = ones(C,C);                          % Initialize transition count matrix

%
% Loop over all of the files in the specified folder
%
filename = dir(fullfile(folder,name));
for book = 1:size(filename,1)
   %
   % Open the file for reading
   %
   filepath = fullfile(folder,filename(book).name);
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
% Convert transition counts to probabilities
% 
M = log(T/sum(sum(T)));

end
