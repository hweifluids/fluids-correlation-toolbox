function [] = CorrVideo(fig_inputdir, fig_numsteps, fig_freq, ...
    vd_framerate, vd_playbackratio)

files = dir(fig_inputdir);
pngCount = 0;
for i = 1:length(files)
    if ~files(i).isdir && strcmpi(files(i).name(end-3:end), '.png')
        pngCount = pngCount + 1;
    end
end

vd_obj = VideoWriter('CorrVideo.avi');
fig_vd_interval = fig_freq / vd_playbackratio / vd_framerate;

for i = 1 : fig_numsteps

end