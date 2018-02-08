function block_order = getBlockOrder(is_gains, gdata, ldata)
%BLOCK_ORDER Determine Condition Order
% Which blocks contain the required domain, across the entirety of the
% experiment? This is required because the imaging file isn't segregated
% between gains and losses. This function extracts them from collected data.
%
%OUTPUT 
% block_order - 1x4 cell that contains the IDs of blocks in a given domain.

% Gets 1x3 matrix of hour, minute, second
gstart = gdata.trialTime(1).trialStartTime(4:6);
lstart = ldata.trialTime(1).trialStartTime(4:6);

if is_gains
    if gstart(1)*60 + gstart(2) > lstart(1)*60 + lstart(2)
        block_order = {'3','4'};
    else
        block_order = {'1','2'};
    end
else
    if gstart(1)*60 + gstart(2) > lstart(1)*60 + lstart(2)
        block_order = {'1','2'};
    else
        block_order = {'3','4'};
    end
end

% NOTE on magical index: 63 = (124 / 2) + 1. In other words, first Day 2 trial.
gstart = gdata.trialTime(63).trialStartTime(4:6);
lstart = ldata.trialTime(63).trialStartTime(4:6);

if is_gains
    if gstart(1)*60 + gstart(2) > lstart(1)*60 + lstart(2)
        block_order{3} = '7'; block_order{4} = '8';
    else
        block_order{3} = '5'; block_order{4} = '6';
    end
else
    if gstart(1)*60 + gstart(2) > lstart(1)*60 + lstart(2)
        block_order{3} = '5'; block_order{4} = '6';
    else
        block_order{3} = '7'; block_order{4} = '8';
    end
end
end
