function normed = CorrNom(unnormed)

sizedata = size(unnormed);
normed = zeros(sizedata);
for i = 1:sizedata(1)
    sig = unnormed(i,:);
    sig_min = min(sig); sig_max = max(sig);
    norm_scale = 1/(sig_max-sig_min);
    sig_norm = ( sig - sig_min ) * norm_scale;
    normed(i,:) = sig_norm;
end

end