cd('Source');

for file = dir('*.c')'
    mex(file.name)
end

cd ..
