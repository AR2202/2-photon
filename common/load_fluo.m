%extract the mean fluorescence for each frame of the tiffstack
function fluo = load_fluo(csvfile)
T = readtable(csvfile);
fluo = transpose(T.Mean);

