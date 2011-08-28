mode(-1);
lines(0);
demosPath=get_absolute_file_path('loaddemos.sce');
add_demo('arkscicos block demos',demosPath+'./blockDemos.sce');
add_demo('arkscicos script demos',demosPath+'./scriptDemos.sce');
clear demosPath
