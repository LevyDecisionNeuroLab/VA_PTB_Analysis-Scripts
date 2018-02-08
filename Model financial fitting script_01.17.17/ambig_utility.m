
function y = ambig_utility(v,p,AL,k1,k2,model)

if strcmp(model,'financial')
    y = v .* p - k1 .* v .^ 2 .*p .* (1 - p) - k2 .* AL .^ 2; %sv = ev - risk premium on risk - risk premium on ambig
end

end
