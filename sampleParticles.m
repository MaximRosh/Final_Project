function S_next_tag = sampleParticles(S_prev, C)
% Initialization
S_next_tag = zeros(size(S_prev));
for i=1:size(C,2)
    % Generate random r
    r = rand(1);
    % find smallest C(j,t-1) > r
    [~, mCol] = find(C > r);
    % set new Value
    S_next_tag(:,i) = S_prev(:, mCol(1));
end