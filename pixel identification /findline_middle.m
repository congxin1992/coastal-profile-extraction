%% 读取当前文件夹内的所有png图片

clear;
clc;
close all;
Profilename = 'correction';
% 获取当前文件夹中所有png文件的文件名
fileList = dir('*.png');
% 遍历文件列表，逐个读取文件
figure(1)
pic0=fileList(1).name;
imshow(pic0);
hold on;

for i = 1:length(fileList)
    filename = fileList(i).name;
    % 使用imread函数读取文件
    img = imread(filename);
    [m,n,color] = size(img);
    img1 = rgb2gray(img);
    R = img(:,:,1);
    G = img(:,:,2);
    B = img(:,:,3);
    clear A1 A2
    [A1,A2] = find(R==235 & G==6 & B==6); % A1-Y A2-X，已经将RGB纠正
    figure(1)
    plot(A2,A1,'-.b','LineWidth',1);
    title(filename);
    hold on;
    %将横纵坐标转化为以水槽底部为0点的坐标系
    A2=8.7-(934-A2)*0.001655;
    A1=(556-A1)*0.001724+0.45;
    
    PDATA = [A2 A1];%已将顺序调整为xy坐标的正确标注
    
    writematrix(PDATA, 'data.xlsx', 'Sheet', i);
end

    
    
    
    
    

