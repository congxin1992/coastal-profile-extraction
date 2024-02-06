%% ��ȡ��ǰ�ļ����ڵ�����pngͼƬ

clear;
clc;
close all;
Profilename = 'correction';
% ��ȡ��ǰ�ļ���������png�ļ����ļ���
fileList = dir('*.png');
% �����ļ��б������ȡ�ļ�
figure(1)
pic0=fileList(1).name;
imshow(pic0);
hold on;

for i = 1:length(fileList)
    filename = fileList(i).name;
    % ʹ��imread������ȡ�ļ�
    img = imread(filename);
    [m,n,color] = size(img);
    img1 = rgb2gray(img);
    R = img(:,:,1);
    G = img(:,:,2);
    B = img(:,:,3);
    clear A1 A2
    [A1,A2] = find(R==235 & G==6 & B==6); % A1-Y A2-X���Ѿ���RGB����
    figure(1)
    plot(A2,A1,'-.b','LineWidth',1);
    title(filename);
    hold on;
    %����������ת��Ϊ��ˮ�۵ײ�Ϊ0�������ϵ
    A2=11.7-(922-A2)*0.001899;
    A1=(526-A1)*0.001923+0.45;
    
    PDATA = [A2 A1];%�ѽ�˳�����Ϊxy�������ȷ��ע
    
    writematrix(PDATA, 'data.xlsx', 'Sheet', i);
end

    
    
    
    
    

