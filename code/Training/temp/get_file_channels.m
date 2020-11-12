files = dir('C:\Users\XuanyuWang\OneDrive - campus.lmu.de\Lab works\JacobLab-MonkeyData\Git\JacobLabMonkey\data\raw_nex\*.nex');
for i = 1:numel(files)
    nexfile = readNexFile(files(i).name);
    channum(i) = length(nexfile.contvars);
end
save('channum','channum');