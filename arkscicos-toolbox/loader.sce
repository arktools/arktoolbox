mode(-1);
lines(0);

origDir=pwd()
arkscicosPath=get_absolute_file_path('loader.sce');

chdir(arkscicosPath);

mprintf('arkscicos version %s\n', stripblanks(read("VERSION",1,1,'(a)')) );
mprintf('Copyright (C) 2012 James Goppert\n\n' );

if isdir('sci_gateway') then
  chdir('sci_gateway');
  exec('loader.sce');
  chdir('..');
end

if isdir('macros') then
  chdir('macros');
  exec('loadmacros.sce');
  chdir('..');
end

if isdir('scicos') then
  chdir('scicos');
  exec('loadscicos.sce');
  chdir('..');
end

if isdir('demos') then
  chdir('demos');
  exec('loaddemos.sce');
  chdir('..');
end

if isdir('help') then
  chdir('help');
  exec('loadhelp.sce');
  chdir('..');
end

chdir(origDir)

clear origDir
