function W = compNormWeights_ilya(I, S, q)

    [~, N] = size(S);

    newW = zeros(1, N);
    
    for i = 1:N
        p = compNormHist(I, S(:, i));
        newW(i) = compBatDist(p, q);
    end

    W = newW / sum(newW);
    
    if sum(isnan(W)) > 0
        W = newW / sum(uint64(newW));
    end
    
    W(isnan(W)) = 0;
end