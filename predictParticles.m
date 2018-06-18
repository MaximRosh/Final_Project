function S_next = predictParticles(S_next_tag)
% Initialize
S_next = zeros(size(S_next_tag));
% Tracking window width and height is not changed
S_next(3, :) = S_next_tag(3, :);
S_next(4, :) = S_next_tag(4, :);

% Random noise
n = randi([-5 5],2,100);
% n = double(int8(randn([2,100])*5));
% n = wgn(2, size(S_next_tag, 2), 10); % must have CV toolbox

% Update velocity
S_next(5, :) = S_next_tag(5, :) + n(1, :);
S_next(6, :) = S_next_tag(6, :) + n(2, :);

% Update center location
S_next(1, :) = S_next_tag(1, :) + S_next(5, :);
S_next(2, :) = S_next_tag(2, :) + S_next(6, :);
end
