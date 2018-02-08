function [ onsets, offsets ] = getBlockOnsetOffset(prtblock, DiscAcq, tr, trialduration)
% GETBLOCKONSETOFFSET Extracts onsets and offsets for a particular choice block
% TODO: ShiftStart argument?
% TODO: NumTrialsDiscard = 1, for prtblock = prtblock((1 + NumTrialsDiscard):31)?
ShiftStart = 0;

% 0. Exclude first trial and round to nearest full second
prtblock = round(prtblock(2:31, :));

% 1. Remove initial N seconds (= Discarded Acquisition) and shift *all* values by N
prtblock = prtblock - DiscAcq; 

% 2. Add M seconds to start time
prtblock(:, 1) = prtblock(:, 1) + ShiftStart;

% 3. Convert all from seconds to volumes (temporal resolutions)
prtblock = prtblock ./ tr;

% 4. Extract the onset and offset values
onsets  = prtblock(:, 1);

% NOTE: there are different offset calculation logics.
offsets = prtblock(:, 2); % offset at the end of choice display period
%offsets = onsets + trialduration; % offset after a slice of display time
%offsets = prtblock(:, 2) - 1; % cut one volume before display end, to account for rounding error
%offsets = prtblock(:, 3); % get a volume that includes deliberation prior to button press
end
