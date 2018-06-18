function w = compBatDist(p,q)
% Compute weights sigma from 1 to 4096 of qi and pi is just q and p
w = exp(20 * sqrt(p)' * sqrt(q));
end