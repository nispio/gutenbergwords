function f_best = decodemessage(x,M,N)

AZ = 27;                      % Number of characters of interest
scale_factor = 1850;          % Probability scale factor

%
% Initialize data arrays
%
F = zeros(N,AZ);
Pl = zeros(N,1);
p_accept = ones(N,1);

%
% Convert the text to the range 1-27
% 
txt = mod(bitand(uint8(x),31),AZ)+1;
L = length(txt);
fprintf(1,'%4d: %s\n',0,char(txt(:).'+95));

%
% Start with a random permutation of the characters
%
F(1,:) = randperm(AZ);

% 
% Determine the plausibility of the initial mapping
% 
p = 0
for c = 2:length(txt)
    Pl(1) = Pl(1) + M(F(1,(txt(c-1))),F(1,(txt(c))));
end
Pl(1) = Pl(1)/length(txt);

%
% Store the most plausible mapping seen so far
%
Pl_best = Pl(1);
f_best = F(1,:);

% 
% Attempt N character swaps in the mapping, favoring the most plausible
% 
for iter = 2:N
    % 
    % Randomly swap two characters in substitution map
    % 
    f = F(iter-1,:);
    ij = randperm(AZ,2);
    f(ij) = f(fliplr(ij));
    
    % 
    % Test the plausibility of the new substitution map
    % 
    p = 0;
    for c = 2:length(txt)
        p = p + M(f(txt(c-1)),f(txt(c)));
    end
    p = p/length(txt);

    % 
    % If the new substitution map is more plausible, then accept
    %  it. If not, accept it with a probability determined by
    %  the difference between them times a scale factor
    % 
    if ( rand() < exp(scale_factor*(p-Pl(iter-1))) )
        F(iter,:) = f;
        Pl(iter) = p;
        % 
        % Test if this is the most plausible mapping we've seen
        % 
        if ( p > Pl_best )
            Pl_best = p;
            f_best = f;
            new_txt = char(f(txt(:)).'+95);
            fprintf(1,'%4d: %s\n',iter,new_txt);
        end
    else
        % Keep the old mapping
        F(iter,:) = F(iter-1,:);
        Pl(iter) = Pl(iter-1);
    end
end

%
% Plot and label the transition probability matrix
%
figure(1); clf;
imagesc(M); axis image;
colormap(gray(256)); colorbar;
title('Letter Transition Probabilities (Log Scale)','FontSize',16);
xlabel('To Letter','FontSize',14);
ylabel('From Letter','FontSize',14);
% Set the arrays used for the plot labels
Tick = 1:27;
tl =char(Tick.'+63);
tl(1) = char('_');
TickLabel = mat2cell(tl,length(Tick),1);
% Show the letters along the axis of the image
set(gca,'TickLength',[0 0]);
set(gca,'XTick',Tick);
set(gca,'XTickLabel',TickLabel);
set(gca,'YTick',Tick);
set(gca,'YTickLabel',TickLabel);

%
% Plot the plausibility over time
%
figure(2); clf;
semilogx(Pl);
title('Plausibility Over Time','FontSize',16);
xlabel('Iteration Number','FontSize',14);
ylabel('Log Plausibility','FontSize',14);

end
