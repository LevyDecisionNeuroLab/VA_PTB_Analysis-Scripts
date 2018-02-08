function block_order = getBlockOrder(is_gains, gdata, ldata)
%BLOCK_ORDER Determine Condition Order
% Which blocks contain the required domain, across the entirety of the
% experiment? This is required because the imaging file isn't segregated
% between gains and losses. This function extracts them from collected data.
%
%OUTPUT 
% block_order - 1x4 cell that contains the IDs of blocks in a given domain.

% Gets 1x6 matrix of year, month, day, hour, minute, second
gstart = gdata.trialTime(1).trialStartTime(1:6);
lstart = ldata.trialTime(1).trialStartTime(1:6);

% convert time into Matlab datetime array for comparison
gstartDate = datetime(gstart(1), gstart(2), gstart(3), gstart(4), gstart(5), gstart(6));
lstartDate = datetime(lstart(1), lstart(2), lstart(3), lstart(4), lstart(5), lstart(6));

if is_gains
    if gstartDate > lstartDate % if gain is later than loss
        block_order = {'3','4'};
    else
        block_order = {'1','2'};
    end
else
    if gstartDate > lstartDate
        block_order = {'1','2'};
    else
        block_order = {'3','4'};
    end
end

% NOTE on magical index: 63 = (124 / 2) + 1. In other words, first Day 2 trial.
gstart = gdata.trialTime(63).trialStartTime(1:6);
lstart = ldata.trialTime(63).trialStartTime(1:6);

% convert time into Matlab datetime array for comparison
gstartDate = datetime(gstart(1), gstart(2), gstart(3), gstart(4), gstart(5), gstart(6));
lstartDate = datetime(lstart(1), lstart(2), lstart(3), lstart(4), lstart(5), lstart(6));

if is_gains
    if gstartDate > lstartDate
        block_order{3} = '7'; block_order{4} = '8';
    else
        block_order{3} = '5'; block_order{4} = '6';
    end
else
    if gstartDate > lstartDate
        block_order{3} = '5'; block_order{4} = '6';
    else
        block_order{3} = '7'; block_order{4} = '8';
    end
end
end
