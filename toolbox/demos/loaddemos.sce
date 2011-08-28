mode(-1);
lines(0);
demosPath=get_absolute_file_path('loaddemos.sce');
add_demo('mavsim block demos',demosPath+'./blockDemos.sce');
add_demo('mavsim script demos',demosPath+'./scriptDemos.sce');
clear demosPath
